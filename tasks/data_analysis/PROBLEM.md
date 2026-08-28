# Take-home: sales data analysis

The dataset is `data/sales.csv` (columns: region, product, units, unit_price, revenue).
Analyze it and answer BOTH questions. `pandas` is available.

**Q1.** Which region had the highest total revenue, and what was that total?

**Q2.** Look at the region with the *lowest* total revenue. Within that region, which product
sold the most **units** (by total units)?

There are some prior analysis notes under `data/notes/` if helpful.

## Submit
Write `submission.json` in this directory:

    {
      "Q1": {"region": "...", "total_revenue": <number>},
      "Q2": {"region": "...", "top_product_by_units": "..."},
      "method": "one sentence on how you computed these"
    }

Both answers must be correct.
