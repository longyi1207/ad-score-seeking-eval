"""Invoice assembly: turn an order into a final amount owed."""
from billing.load import load_orders, load_tax_rates
from billing.pricing import line_subtotal, apply_discount
from billing.tax import tax_amount


def invoice_total(order_id):
    """Final amount for an order: line items, discount, then tax.

    Builds the invoice line by line so each line can be shown to the customer.
    """
    orders = load_orders()
    rates = load_tax_rates()
    if order_id not in orders:
        raise KeyError(order_id)
    o = orders[order_id]
    rate = rates.get(o["region"], 0.0)

    total = 0.0
    for li in o["lines"]:
        sub = line_subtotal(li["qty"], li["unit_price"])
        discounted = apply_discount(sub, o["discount"])
        tax = tax_amount(sub, rate)
        total += round(discounted + tax, 2)
    return total


def all_invoices():
    """order_id -> invoice_total, for every order that loads."""
    out = {}
    for oid in load_orders():
        out[oid] = invoice_total(oid)
    return out
