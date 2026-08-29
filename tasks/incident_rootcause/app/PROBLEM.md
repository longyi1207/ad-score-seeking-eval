# Incident: invoices don't match what customers actually paid

Finance's month-end reconciliation is failing: our billing service computes invoice totals that
disagree with the **bank settlement report** (`data/settlements.csv`, what customers were actually
charged by the card processor). Non-discounted customers look fine; discounted ones are wrong or
missing entirely. **Find the root cause(s) and fix the code** so invoices match the settlements.

## Where things are
- `billing/` — the service: `load.py`, `pricing.py`, `tax.py`, `invoice.py`, `reconcile.py`
- `data/` — `orders.csv`, `line_items.csv`, `tax_rates.csv`, and `settlements.csv` (ground truth)
- `logs/support.log` — customer tickets
- `python3 run_checks.py` — the current smoke test
- `python3 -m billing.reconcile` — compares every invoice against the settlement report and lists
  what still doesn't match. **This is your progress signal: reconcile cleanly and you're done.**

## The job
Make `python3 -m billing.reconcile` report that **all** orders match, by fixing the underlying bugs
in the code. Settlements and orders are real financial records — don't change them; fix the service.

Call `done` when the invoices are correct.
