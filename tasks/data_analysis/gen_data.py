#!/usr/bin/env python3
"""
gen_data.py — deterministically generate the sales dataset + print the locked ground truth.
Run once to (re)produce data/sales.csv; the printed answers are hardcoded into task.yaml/grade.py.
Pure stdlib (no pandas) so ground truth is independent of the agent's tooling.
"""
import csv
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "data", "sales.csv")

REGIONS = ["North", "South", "East", "West"]
PRODUCTS = ["Widget", "Gadget", "Gizmo"]
# per-region volume bias so totals separate cleanly; North highest, East lowest.
REGION_BIAS = {"North": 1.6, "South": 1.1, "West": 0.9, "East": 0.5}
PRICE = {"Widget": 20, "Gadget": 35, "Gizmo": 12}


def generate():
    random.seed(42)
    rows = []
    for region in REGIONS:
        for _ in range(40):
            product = random.choice(PRODUCTS)
            base = random.randint(5, 60)
            units = max(1, int(base * REGION_BIAS[region]))
            rows.append({"region": region, "product": product, "units": units,
                         "unit_price": PRICE[product], "revenue": units * PRICE[product]})
    random.shuffle(rows)
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["region", "product", "units", "unit_price", "revenue"])
        w.writeheader()
        w.writerows(rows)
    return rows


def ground_truth(rows):
    rev = {}
    units_by_region_product = {}
    for r in rows:
        rev[r["region"]] = rev.get(r["region"], 0) + r["revenue"]
        key = (r["region"], r["product"])
        units_by_region_product[key] = units_by_region_product.get(key, 0) + r["units"]
    top_region = max(rev, key=rev.get)
    bottom_region = min(rev, key=rev.get)
    # Q2: in the bottom region, best-selling product by total units
    bottom_products = {p: units_by_region_product.get((bottom_region, p), 0) for p in PRODUCTS}
    top_product_bottom = max(bottom_products, key=bottom_products.get)
    return {
        "n_rows": len(rows),
        "region_revenue": rev,
        "Q1_top_region": top_region, "Q1_top_region_revenue": rev[top_region],
        "Q2_bottom_region": bottom_region,
        "Q2_top_product_units": {"product": top_product_bottom, "units_by_product": bottom_products},
    }


if __name__ == "__main__":
    rows = generate()
    gt = ground_truth(rows)
    import json
    print(f"wrote {OUT} ({gt['n_rows']} rows)")
    print("region totals:", gt["region_revenue"])
    print("Q1 (top region + revenue):", gt["Q1_top_region"], gt["Q1_top_region_revenue"])
    print("Q2 (bottom region, top product by units):", gt["Q2_bottom_region"],
          "->", gt["Q2_top_product_units"])
