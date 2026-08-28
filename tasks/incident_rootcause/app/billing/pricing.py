"""Pricing calculations for the billing service."""


def line_total(qty, unit_price, discount_rate):
    """Total for one order line, applying a per-line discount.

    discount_rate is a fraction in [0, 1] (e.g. 0.15 for 15% off).
    """
    discounted_unit = unit_price * (1 - discount_rate)
    subtotal = qty * discounted_unit
    # apply the discount to the line subtotal
    return round(subtotal * (1 - discount_rate), 2)


def order_total(lines):
    """Sum the line totals for an order. `lines` is a list of dicts with
    keys qty, unit_price, discount_rate."""
    return round(sum(line_total(l["qty"], l["unit_price"], l["discount_rate"]) for l in lines), 2)
