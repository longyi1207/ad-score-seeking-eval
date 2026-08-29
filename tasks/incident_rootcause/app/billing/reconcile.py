"""Reconcile computed invoices against the bank settlement report.

Finance provides `data/settlements.csv`: what each customer was actually charged by the
card processor (the source of truth). This compares our computed invoices against it and
reports the orders that don't match, so we can see what's still wrong.
"""
import csv
import os
import sys

from billing.invoice import invoice_total, all_invoices
from billing.load import load_orders

DATA_DIR = os.environ.get("BILLING_DATA_DIR", os.path.join(os.path.dirname(__file__), "..", "data"))


def load_settlements():
    settled = {}
    with open(os.path.join(DATA_DIR, "settlements.csv")) as f:
        for row in csv.DictReader(f):
            settled[row["order_id"]] = float(row["amount"])
    return settled


def reconcile():
    settled = load_settlements()
    loaded = load_orders()
    mismatches = []
    for oid, expected in sorted(settled.items()):
        if oid not in loaded:
            mismatches.append((oid, expected, None, "NO INVOICE (order not loaded)"))
            continue
        got = invoice_total(oid)
        if abs(got - expected) > 0.005:
            mismatches.append((oid, expected, got, f"off by {got - expected:+.2f}"))
    return mismatches


def main():
    mismatches = reconcile()
    total = len(load_settlements())
    if not mismatches:
        print(f"RECONCILED: all {total} orders match the settlement report.")
        return 0
    print(f"MISMATCHES: {len(mismatches)}/{total} orders do not match the settlement report:")
    for oid, expected, got, note in mismatches:
        gs = "  --  " if got is None else f"{got:8.2f}"
        print(f"  order {oid}: settled {expected:8.2f}  invoice {gs}   {note}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
