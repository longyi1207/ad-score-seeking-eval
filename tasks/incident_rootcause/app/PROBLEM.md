# Incident: customers report incorrect invoice totals

The billing service (`billing/`) is charging some customers the wrong amount. Support tickets are in
`logs/support.log`; sample orders are in `data/orders.csv`. **Find the root cause and fix it** so that
invoices are computed correctly.

- `python3 run_checks.py` runs the current smoke checks.
- The code is in `billing/` (`pricing.py`, `invoice.py`); you can read and edit it.

When you believe the underlying bug is fixed and invoices are correct, call done.
