# ✈️ Federal Employee Travel Expense Analysis — SQL Showcase

SQL analysis of employee travel expenses across federal program offices, built to mirror the type of spend tracking I performed professionally at a federal consulting firm. Dataset is synthetic; program office names and travel purpose details have been generalized due to clearance requirements.

---

## Background

In my work as a Data Analyst supporting federal clients, I regularly tracked and analyzed employee travel spend by expense type, program office, and trip purpose. This project replicates that analytical workflow using a synthetic dataset built around the same structure I worked with — employee IDs, program offices, expense categories, mileage reimbursements, and travel purposes.

---

## Dataset Overview

| Attribute | Detail |
|---|---|
| Records | 2,000 travel expense records |
| Employees | 150 synthetic employees |
| Program Offices | 6 (anonymized acronyms) |
| Fiscal Year | Oct 2023 – Sep 2024 |
| Expense Types | Mileage, Ground Transportation, Air Transportation, Hotel/Lodging |
| Travel Purposes | Asset Management, Asset Movement |

> Program office names and travel purpose details have been generalized. Actual values are withheld per clearance requirements from prior federal work.

---

## Business Questions Answered

| # | Question | SQL Concepts |
|---|---|---|
| 1 | Which expense types drive the most travel cost? | `GROUP BY`, `SUM`, `AVG`, `MIN`, `MAX` |
| 2 | Which program offices spend the most on travel? | Aggregation + per-employee spend calculation |
| 3 | How does expense type break down within each office? | Multi-column `GROUP BY` |
| 4 | Are there end-of-fiscal-year spending surges? | Date truncation with `strftime()` |
| 5 | How does cumulative spend track against the year? | CTE + `SUM() OVER` running total |
| 6 | Which employees are spending above their office average? | Multi-CTE + `JOIN` + variance calculation |
| 7 | How much is mileage reimbursement costing by office and grade? | Filtered aggregation + `JOIN` |
| 8 | Does travel purpose affect cost by expense type? | Multi-dimension `GROUP BY` comparison |

---

## Files

```
sql_travel_expense_analysis/
├── travel_schema.sql       # Table definitions
├── travel_analysis.sql     # 8 business analysis queries
├── employees.csv           # 150 synthetic employee records
├── travel_expenses.csv     # 2,000 synthetic travel expense records
└── README.md
```

---

## How to Run

**Option 1 — SQLite CLI**
```bash
sqlite3 travel.db
.mode csv
.import employees.csv employees
.import travel_expenses.csv travel_expenses
.read travel_schema.sql
.read travel_analysis.sql
```

**Option 2 — DB Browser for SQLite (GUI)**
1. Download [DB Browser for SQLite](https://sqlitebrowser.org/)
2. Open → New Database → Import both CSVs
3. Open `travel_analysis.sql` in the Execute SQL tab and run

---

## What I Learned Building This

The mileage reimbursement query (Query 7) was the most interesting to write — in real work, mileage data lives separately from other expense types and requires extra handling for null values. Using `WHERE expense_type = 'Mileage'` to isolate those records before aggregating mirrors exactly how I approached it on the job.

Query 6 (employees above office average) is the one I'd flag for a real audit workflow — the variance column makes it easy to sort and prioritize who to review first.

---

## Skills Demonstrated

`GROUP BY` · `Aggregations` · `CTEs` · `Window Functions` · `JOIN` · `Date Engineering` · `strftime()` · `Filtered Aggregations` · `Variance Analysis` · `NULLIF / COALESCE`

---

*Dataset is fully synthetic. All program details, office names, and travel purposes have been generalized or anonymized.*
