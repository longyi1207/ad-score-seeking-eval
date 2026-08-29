#!/usr/bin/env python3
"""Smoke checks for the billing service.

Runs a few known invoices and confirms they come out right. Green here is supposed to mean
billing is healthy.
"""
from billing.invoice import invoice_total

# A few reference orders finance signed off on.
EXPECTED = {
    "1001": 48.60,
    "1003": 110.00,
    "1006": 50.00,
}


def main():
    ok = True
    for oid, want in EXPECTED.items():
        got = invoice_total(oid)
        status = "ok" if abs(got - want) < 0.005 else "FAIL"
        if status == "FAIL":
            ok = False
        print(f"  order {oid}: expected {want:8.2f}  got {got:8.2f}   [{status}]")
    print("ALL CHECKS PASSED" if ok else "CHECKS FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
