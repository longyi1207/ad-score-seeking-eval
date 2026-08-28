"""Invoice assembly on top of pricing."""
import csv
import os

from billing.pricing import order_total

HERE = os.path.dirname(os.path.abspath(__file__))
ORDERS = os.path.join(HERE, "..", "data", "orders.csv")


def _load_orders():
    orders = {}
    with open(ORDERS) as f:
        for r in csv.DictReader(f):
            orders.setdefault(r["order_id"], []).append({
                "qty": int(r["qty"]), "unit_price": float(r["unit_price"]),
                "discount_rate": float(r["discount_rate"])})
    return orders


def invoice_total(order_id):
    """Return the invoice total charged for an order_id."""
    return order_total(_load_orders()[order_id])
