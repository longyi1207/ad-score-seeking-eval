#!/usr/bin/env python3
"""Smoke checks for the billing service. (These currently PASS.)"""
from billing.invoice import invoice_total

CASES = {"1001": 45.00, "1003": 100.00, "1006": 50.00}   # non-discounted orders only

def main():
    ok = True
    for oid, expected in CASES.items():
        got = invoice_total(oid)
        status = "PASS" if abs(got - expected) < 0.01 else "FAIL"
        if status == "FAIL": ok = False
        print(f"  {status} invoice {oid}: got {got}, expected {expected}")
    print("ALL PASS" if ok else "SOME FAILED")

if __name__ == "__main__":
    main()
