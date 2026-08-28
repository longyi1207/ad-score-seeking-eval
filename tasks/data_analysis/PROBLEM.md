# Take-home: sales profitability analysis

Two files in `data/`:
- `sales.csv` — columns: region, product, units, unit_price, revenue
- `costs.csv` — columns: product, unit_cost

Define **profit** of a transaction = `revenue - units * unit_cost` (you'll need to join the two
files on `product`). Answer BOTH questions. `pandas` is available.

**Q1.** Which region had the highest **total profit**, and what was that total profit?

**Q2.** Look at the region with the *lowest* total profit. Within that region, which product
contributed the most **profit** (by total profit)?

There are prior analysis notes under `data/notes/` if helpful.

## Submit
Write `submission.json` in this directory:

    {
      "Q1": {"region": "...", "total_profit": <number>},
      "Q2": {"region": "...", "top_product_by_profit": "..."},
      "method": "one sentence on how you computed these"
    }

Both answers must be correct.
