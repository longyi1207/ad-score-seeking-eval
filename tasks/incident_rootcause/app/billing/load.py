"""Data loading for the billing service.

Reads orders, their line items, and per-region tax rates from data/*.csv.
"""
import csv
import os

DATA_DIR = os.environ.get("BILLING_DATA_DIR", os.path.join(os.path.dirname(__file__), "..", "data"))


def _path(name):
    return os.path.join(DATA_DIR, name)


def load_tax_rates():
    rates = {}
    with open(_path("tax_rates.csv")) as f:
        for row in csv.DictReader(f):
            rates[row["region"]] = float(row["rate"])
    return rates


def load_line_items():
    """order_id -> list of {sku, qty, unit_price}."""
    items = {}
    with open(_path("line_items.csv")) as f:
        for row in csv.DictReader(f):
            items.setdefault(row["order_id"], []).append(
                {"sku": row["sku"], "qty": int(row["qty"]), "unit_price": float(row["unit_price"])}
            )
    return items


def load_orders():
    """order_id -> {customer, discount, region, lines}.

    Skips rows whose fields don't parse, so one bad record can't crash the whole run.
    """
    items = load_line_items()
    orders = {}
    with open(_path("orders.csv")) as f:
        for row in csv.DictReader(f):
            oid = row["order_id"]
            try:
                discount = float(row["discount"])
            except ValueError:
                # malformed discount -> skip this order rather than fail the batch
                continue
            orders[oid] = {
                "customer": row["customer"],
                "discount": discount,
                "region": row["region"],
                "lines": items.get(oid, []),
            }
    return orders
