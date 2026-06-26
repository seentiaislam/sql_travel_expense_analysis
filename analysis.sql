-- ============================================================
-- Financial Transaction Analytics
-- Core Analysis Queries
-- Author: Seentia Islam
-- ============================================================


-- -------------------------------------------------------
-- Query 1: Monthly Spending Trends with Running Total
-- Window function: SUM() OVER with ORDER BY
-- Business use: Track revenue trends month over month
-- -------------------------------------------------------
SELECT
    strftime('%Y-%m', transaction_date)          AS month,
    COUNT(*)                                      AS transaction_count,
    ROUND(SUM(amount), 2)                         AS monthly_spend,
    ROUND(SUM(SUM(amount)) OVER (
        ORDER BY strftime('%Y-%m', transaction_date)
    ), 2)                                         AS running_total
FROM transactions
WHERE is_fraud = 0
GROUP BY month
ORDER BY month;


-- -------------------------------------------------------
-- Query 2: Customer Spending Segmentation
-- CTE + CASE to bucket customers by total annual spend
-- Business use: Identify high-value vs at-risk customers
-- -------------------------------------------------------
WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.credit_limit,
        ROUND(SUM(t.amount), 2)          AS total_spend,
        COUNT(t.transaction_id)          AS txn_count
    FROM customers c
    JOIN transactions t ON c.customer_id = t.customer_id
    WHERE t.is_fraud = 0
    GROUP BY c.customer_id, c.credit_limit
)
SELECT
    customer_id,
    credit_limit,
    total_spend,
    txn_count,
    ROUND(total_spend / credit_limit * 100, 1) AS utilization_pct,
    CASE
        WHEN total_spend >= 5000  THEN 'High Value'
        WHEN total_spend >= 2000  THEN 'Mid Tier'
        WHEN total_spend >= 500   THEN 'Low Engagement'
        ELSE                           'Dormant'
    END AS customer_segment
FROM customer_spend
ORDER BY total_spend DESC;


-- -------------------------------------------------------
-- Query 3: Fraud Detection — Transactions Exceeding
--          3x the Customer's Average Spend
-- CTE + window average to flag anomalies
-- Business use: Rule-based fraud alerting
-- -------------------------------------------------------
WITH customer_avg AS (
    SELECT
        customer_id,
        ROUND(AVG(amount), 2) AS avg_spend
    FROM transactions
    WHERE is_fraud = 0
    GROUP BY customer_id
)
SELECT
    t.transaction_id,
    t.customer_id,
    t.transaction_date,
    t.merchant,
    t.category,
    t.amount,
    ca.avg_spend,
    ROUND(t.amount / ca.avg_spend, 1) AS spend_ratio,
    t.is_fraud                         AS flagged_in_data
FROM transactions t
JOIN customer_avg ca ON t.customer_id = ca.customer_id
WHERE t.amount > (ca.avg_spend * 3)
ORDER BY spend_ratio DESC
LIMIT 20;


-- -------------------------------------------------------
-- Query 4: Category Spend Share by State
-- Aggregation + ROUND to analyze regional behavior
-- Business use: Regional marketing & product targeting
-- -------------------------------------------------------
SELECT
    state,
    category,
    ROUND(SUM(amount), 2)                                   AS category_spend,
    ROUND(SUM(amount) * 100.0 / SUM(SUM(amount)) OVER (
        PARTITION BY state
    ), 1)                                                   AS pct_of_state_spend
FROM transactions
WHERE is_fraud = 0
GROUP BY state, category
ORDER BY state, category_spend DESC;


-- -------------------------------------------------------
-- Query 5: Customer Retention — Month-over-Month Active Users
-- CTE + LAG() to compare active customers across months
-- Business use: Churn monitoring and retention tracking
-- -------------------------------------------------------
WITH monthly_active AS (
    SELECT
        strftime('%Y-%m', transaction_date) AS month,
        COUNT(DISTINCT customer_id)         AS active_customers
    FROM transactions
    WHERE is_fraud = 0
    GROUP BY month
)
SELECT
    month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY month)  AS prev_month_active,
    active_customers - LAG(active_customers) OVER (ORDER BY month) AS mom_change
FROM monthly_active
ORDER BY month;


-- -------------------------------------------------------
-- Query 6: Top 5 Merchants per Category by Revenue
-- CTE + RANK() window function
-- Business use: Merchant partnership prioritization
-- -------------------------------------------------------
WITH merchant_revenue AS (
    SELECT
        category,
        merchant,
        ROUND(SUM(amount), 2)  AS total_revenue,
        COUNT(*)               AS txn_count
    FROM transactions
    WHERE is_fraud = 0
    GROUP BY category, merchant
),
ranked AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS revenue_rank
    FROM merchant_revenue
)
SELECT *
FROM ranked
WHERE revenue_rank <= 5
ORDER BY category, revenue_rank;


-- -------------------------------------------------------
-- Query 7: High-Risk Customer Profile
-- Multi-CTE identifying customers with fraud + high spend
-- Business use: Risk scoring and account review prioritization
-- -------------------------------------------------------
WITH fraud_counts AS (
    SELECT
        customer_id,
        COUNT(*) AS fraud_txn_count,
        ROUND(SUM(amount), 2) AS fraud_total
    FROM transactions
    WHERE is_fraud = 1
    GROUP BY customer_id
),
legit_spend AS (
    SELECT
        customer_id,
        ROUND(SUM(amount), 2) AS legit_total,
        COUNT(*) AS legit_count
    FROM transactions
    WHERE is_fraud = 0
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.age,
    c.state,
    c.credit_limit,
    COALESCE(ls.legit_total, 0)      AS legit_spend,
    COALESCE(fc.fraud_txn_count, 0)  AS fraud_txn_count,
    COALESCE(fc.fraud_total, 0)      AS fraud_amount,
    ROUND(COALESCE(fc.fraud_total, 0) /
          NULLIF(COALESCE(ls.legit_total, 0) + COALESCE(fc.fraud_total, 0), 0) * 100, 1
    ) AS fraud_rate_pct
FROM customers c
LEFT JOIN legit_spend ls ON c.customer_id = ls.customer_id
LEFT JOIN fraud_counts fc ON c.customer_id = fc.customer_id
WHERE COALESCE(fc.fraud_txn_count, 0) > 0
ORDER BY fraud_rate_pct DESC, fraud_amount DESC;


-- -------------------------------------------------------
-- Query 8: Weekend vs Weekday Spending Behavior
-- CASE + strftime to derive time-based features
-- Business use: Optimize marketing campaign scheduling
-- -------------------------------------------------------
SELECT
    CASE
        WHEN CAST(strftime('%w', transaction_date) AS INTEGER) IN (0, 6)
        THEN 'Weekend'
        ELSE 'Weekday'
    END                              AS day_type,
    category,
    COUNT(*)                         AS txn_count,
    ROUND(AVG(amount), 2)            AS avg_spend,
    ROUND(SUM(amount), 2)            AS total_spend
FROM transactions
WHERE is_fraud = 0
GROUP BY day_type, category
ORDER BY day_type, total_spend DESC;
