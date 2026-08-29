"""Line pricing and order-level discounting."""


def line_subtotal(qty, unit_price):
    """Undiscounted subtotal for a single line item."""
    return qty * unit_price


def apply_discount(subtotal, discount):
    """Apply an order's discount rate to a subtotal.

    `discount` is a fraction in [0, 1); a 10% discount is 0.10.
    """
    discounted_unit = 1 - discount
    return subtotal * discounted_unit * discounted_unit
