#!/usr/bin/env python3
"""verify_staging.py — prove the four bugs form a genuine staged chain (dev tool, not shipped).

The design claim (docs/LONG_HORIZON_DESIGN.md: discovered decomposition) is that each bug is
*masked* until the one before it is fixed, so the honest path is an iterative fix->reconcile->fix
loop rather than a single static read. This applies the fixes cumulatively and checks that the set
of orders reconciling against settlements GROWS one stage at a time — and never all at once.

Run from the task root with the app dir importable:  python3 verify_staging.py
"""
import csv
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
APP = os.path.join(HERE, "app")
sys.path.insert(0, APP)

TAX = {"CA": 0.08, "NY": 0.10, "TX": 0.00}


def load_orders_raw(fix_parse):
    """Load orders; fix_parse=True applies the STAGE-1 fix (parse 'N%' strings)."""
    items = {}
    with open(os.path.join(APP, "data", "line_items.csv")) as f:
        for r in csv.DictReader(f):
            items.setdefault(r["order_id"], []).append((int(r["qty"]), float(r["unit_price"])))
    orders = {}
    with open(os.path.join(APP, "data", "orders.csv")) as f:
        for r in csv.DictReader(f):
            s = r["discount"]
            try:
                disc = (float(s[:-1]) / 100) if (fix_parse and s.endswith("%")) else float(s)
            except ValueError:
                continue  # unfixed parse bug drops 'N%' rows
            orders[r["order_id"]] = {"discount": disc, "region": r["region"], "lines": items.get(r["order_id"], [])}
    return orders


def invoice(o, fixes):
    """Compute an invoice total under a set of applied fixes.

    fixes: subset of {'discount','tax','round'}. Absent fix => that bug is active.
    (stage-1 'parse' fix is handled in load_orders_raw.)
    """
    rate = TAX[o["region"]]
    disc = o["discount"]

    def line(qty, price):
        sub = qty * price
        # BUG2 (discount) active unless fixed
        discounted = sub * (1 - disc) if "discount" in fixes else sub * (1 - disc) * (1 - disc)
        # BUG3 (tax base) active unless fixed: buggy taxes pre-discount sub
        tax = (discounted if "tax" in fixes else sub) * rate
        return discounted, tax

    if "round" in fixes:  # round once at invoice level
        tot_d = tot_t = 0.0
        for qty, price in o["lines"]:
            d, t = line(qty, price)
            tot_d += d
            tot_t += t
        return round(tot_d + tot_t, 2)
    else:                 # BUG4: round each line then sum
        return sum(round(d + t, 2) for d, t in (line(qty, price) for qty, price in o["lines"]))


def settlements():
    out = {}
    with open(os.path.join(APP, "data", "settlements.csv")) as f:
        for r in csv.DictReader(f):
            out[r["order_id"]] = float(r["amount"])
    return out


def stage_state(parse, fixes):
    """Return (loaded_and_settled, reconciled) sets for a stage."""
    settled = settlements()
    orders = load_orders_raw(parse)
    loaded = {oid for oid in settled if oid in orders}
    ok = {oid for oid, exp in settled.items()
          if oid in orders and abs(invoice(orders[oid], fixes) - exp) <= 0.005}
    return loaded, ok


def main():
    stages = [
        ("0. no fixes",               False, set()),
        ("1. + parse ('N%')",         True,  set()),
        ("2. + discount (single)",    True,  {"discount"}),
        ("3. + tax on discounted",    True,  {"discount", "tax"}),
        ("4. + round once",           True,  {"discount", "tax", "round"}),
    ]
    all_ids = set(settlements())
    prev_loaded = prev_ok = None
    print(f"{len(all_ids)} orders total: {sorted(all_ids)}\n")
    ok_all = True
    for label, parse, fixes in stages:
        loaded, ok = stage_state(parse, fixes)
        newly_ok = ok - prev_ok if prev_ok is not None else ok
        newly_loaded = loaded - prev_loaded if prev_loaded is not None else loaded
        # progress = this fix either reconciles a new order OR first makes new orders visible
        # (loaded but still wrong -> the reconcile report changes from "NO INVOICE" to "off by X")
        detail = f"newly_reconciled={sorted(newly_ok)}"
        if newly_loaded and not newly_ok:
            detail = f"newly_visible(still wrong)={sorted(newly_loaded)}"
        print(f"{label:28s} loaded={len(loaded)}/{len(all_ids)} reconciled={len(ok)}/{len(all_ids)}  {detail}")
        if prev_ok is not None:
            if not (ok >= prev_ok):        # monotonic: never un-reconcile a fixed order
                print("  !! REGRESSION: a previously-reconciled order broke"); ok_all = False
            if not newly_ok and not newly_loaded:
                print("  !! NO PROGRESS: this fix changed nothing in the reconcile report"); ok_all = False
        prev_loaded, prev_ok = loaded, ok
    _, final = stage_state(True, {"discount", "tax", "round"})
    print()
    if final == all_ids and ok_all:
        print("PASS: staged chain verified — each fix reveals the next, all reconcile only at the end.")
        return 0
    print(f"FAIL: final reconciled {sorted(final)} != all {sorted(all_ids)}, or staging not monotone/progressive.")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
