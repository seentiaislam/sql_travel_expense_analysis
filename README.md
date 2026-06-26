# 💳 Financial Transaction Analytics — SQL Showcase

End-to-end SQL analysis of 5,000 synthetic credit card transactions across 200 customers, designed to surface business insights in fraud detection, customer segmentation, and spending behavior.

---

## Project Overview

| Attribute | Detail |
|---|---|
| Dataset | Synthetic credit card transactions (2024) |
| Records | 5,000 transactions · 200 customers |
| Categories | Groceries, Dining, Travel, Shopping, Healthcare, Gas, Utilities, Entertainment |
| Fraud Rate | ~3% flagged transactions |
| SQL Dialect | SQLite (portable — runs locally with no setup) |

---

## Business Questions Answered

| # | Question | SQL Concepts |
|---|---|---|
| 1 | How does monthly spend trend over the year? | Window function: `SUM() OVER` running total |
| 2 | Which customers are high-value vs dormant? | CTE + `CASE` segmentation |
| 3 | Which transactions look like fraud? | CTE + anomaly threshold (3x avg spend) |
| 4 | How does category spend vary by state? | `SUM() OVER PARTITION BY` share calculation |
| 5 | Are we retaining active customers month over month? | CTE + `LAG()` for MoM comparison |
| 6 | Which merchants drive the most revenue per category? | CTE + `RANK() OVER PARTITION BY` |
| 7 | Which customers have the highest fraud risk profile? | Multi-CTE + `COALESCE` + `NULLIF` |
| 8 | Do customers spend differently on weekends vs weekdays? | `strftime()` date feature engineering |

---

## Files

```
sql_financial_analytics/
├── schema.sql          # Table definitions
├── analysis.sql        # 8 business analysis queries
├── customers.csv       # 200 synthetic customer records
├── transactions.csv    # 5,000 synthetic transaction records
└── README.md
```

---

## How to Run

**Option 1 — SQLite CLI**
```bash
sqlite3 finance.db
.mode csv
.import customers.csv customers
.import transactions.csv transactions
.read schema.sql
.read analysis.sql
```

**Option 2 — DB Browser for SQLite (GUI)**
1. Download [DB Browser for SQLite](https://sqlitebrowser.org/)
2. Open → New Database → Import both CSVs
3. Open `analysis.sql` in the Execute SQL tab and run

---

## Key Findings

- **Travel** drives the highest average transaction amount across all states
- Fraud-flagged transactions average **8x** the customer's normal spend
- **Weekend** dining and entertainment spend is notably higher than weekday
- Top 20% of customers account for over 60% of total legitimate spend

---

## Skills Demonstrated

`Window Functions` · `CTEs` · `Aggregations` · `JOIN` · `CASE` · `Date Engineering` · `Fraud Detection Logic` · `Customer Segmentation` · `RANK / LAG / PARTITION BY` · `COALESCE / NULLIF`

---

*Dataset is fully synthetic and generated for portfolio purposes. No real customer data used.*
