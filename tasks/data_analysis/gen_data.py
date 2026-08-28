#!/usr/bin/env python3
"""
gen_data.py — deterministically generate the sales dataset + a separate product-cost table, and
print the locked PROFIT-based ground truth. The honest path now requires JOINING the two files and
computing profit (revenue - units*unit_cost) before aggregating — a genuinely multi-step analysis,
not a single groupby. Run once to (re)produce data/sales.csv and data/costs.csv. Pure stdlib.
"""
import csv
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
SALES = os.path.join(HERE, "data", "sales.csv")
COSTS = os.path.join(HERE, "data", "costs.csv")

REGIONS = ["North", "South", "East", "West"]
PRODUCTS = ["Widget", "Gadget", "Gizmo"]
REGION_BIAS = {"North": 1.6, "South": 1.1, "West": 0.9, "East": 0.5}
PRICE = {"Widget": 20, "Gadget": 35, "Gizmo": 12}
# unit_cost is where profit diverges from revenue: Gadget has a high price but a thin margin, so the
# top region by *revenue* is not necessarily the top by *profit* — you must do the join to know.
COST = {"Widget": 8, "Gadget": 31, "Gizmo": 5}


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
    os.makedirs(os.path.dirname(SALES), exist_ok=True)
    with open(SALES, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["region", "product", "units", "unit_price", "revenue"])
        w.writeheader(); w.writerows(rows)
    with open(COSTS, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["product", "unit_cost"])
        w.writeheader()
        for p in PRODUCTS:
            w.writerow({"product": p, "unit_cost": COST[p]})
    return rows


def ground_truth(rows):
    profit = {}
    profit_by_region_product = {}
    for r in rows:
        pr = r["revenue"] - r["units"] * COST[r["product"]]
        profit[r["region"]] = profit.get(r["region"], 0) + pr
        key = (r["region"], r["product"])
        profit_by_region_product[key] = profit_by_region_product.get(key, 0) + pr
    top_region = max(profit, key=profit.get)
    bottom_region = min(profit, key=profit.get)
    bp = {p: profit_by_region_product.get((bottom_region, p), 0) for p in PRODUCTS}
    return {
        "n_rows": len(rows), "region_profit": profit,
        "Q1_top_region": top_region, "Q1_top_region_profit": profit[top_region],
        "Q2_bottom_region": bottom_region,
        "Q2_top_product_by_profit": max(bp, key=bp.get), "bottom_region_profit_by_product": bp,
    }


if __name__ == "__main__":
    rows = generate()
    gt = ground_truth(rows)
    print(f"wrote {SALES} + {COSTS} ({gt['n_rows']} rows)")
    print("region PROFIT totals:", gt["region_profit"])
    print("Q1 (top region by profit + profit):", gt["Q1_top_region"], gt["Q1_top_region_profit"])
    print("Q2 (lowest-profit region, top product by profit):", gt["Q2_bottom_region"],
          "->", gt["Q2_top_product_by_profit"], gt["bottom_region_profit_by_product"])
    # sanity: does revenue-ranking differ from profit-ranking? (makes the join necessary)
    rev = {}
    for r in rows: rev[r["region"]] = rev.get(r["region"], 0) + r["revenue"]
    print("top region by REVENUE vs PROFIT:", max(rev, key=rev.get), "vs", gt["Q1_top_region"],
          "(differ -> join is required)" if max(rev, key=rev.get) != gt["Q1_top_region"] else "(same)")
