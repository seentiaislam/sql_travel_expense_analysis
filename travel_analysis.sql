-- ============================================================
-- Federal Employee Travel Expense Analysis
-- Core Analysis Queries
-- Author: Seentia Islam
-- ============================================================


-- -------------------------------------------------------
-- Query 1: Total Spend by Expense Type
-- Simple aggregation — what is driving travel costs?
-- Business use: Identify which expense categories to target
--               for cost reduction policy
-- -------------------------------------------------------
SELECT
    expense_type,
    COUNT(*)                        AS trip_count,
    ROUND(SUM(amount), 2)           AS total_spend,
    ROUND(AVG(amount), 2)           AS avg_per_trip,
    ROUND(MIN(amount), 2)           AS min_spend,
    ROUND(MAX(amount), 2)           AS max_spend
FROM travel_expenses
GROUP BY expense_type
ORDER BY total_spend DESC;


-- -------------------------------------------------------
-- Query 2: Program Office Spend Summary
-- Which offices are driving the most travel costs?
-- Business use: Budget allocation and office-level auditing
-- -------------------------------------------------------
SELECT
    program_office,
    COUNT(DISTINCT employee_id)     AS employee_count,
    COUNT(*)                        AS total_trips,
    ROUND(SUM(amount), 2)           AS total_spend,
    ROUND(AVG(amount), 2)           AS avg_spend_per_trip,
    ROUND(SUM(amount) / COUNT(DISTINCT employee_id), 2) AS avg_spend_per_employee
FROM travel_expenses
GROUP BY program_office
ORDER BY total_spend DESC;


-- -------------------------------------------------------
-- Query 3: Expense Type Breakdown Within Each Office
-- Nested aggregation to see cost composition by office
-- Business use: Spot offices over-relying on air travel
--               vs mileage reimbursement
-- -------------------------------------------------------
SELECT
    program_office,
    expense_type,
    COUNT(*)                AS trip_count,
    ROUND(SUM(amount), 2)   AS total_spend
FROM travel_expenses
GROUP BY program_office, expense_type
ORDER BY program_office, total_spend DESC;


-- -------------------------------------------------------
-- Query 4: Monthly Spend Trend by Office
-- Are travel costs increasing toward fiscal year end?
-- Business use: Detect end-of-year spending surges
-- -------------------------------------------------------
SELECT
    strftime('%Y-%m', travel_date)  AS month,
    program_office,
    COUNT(*)                        AS trip_count,
    ROUND(SUM(amount), 2)           AS monthly_spend
FROM travel_expenses
GROUP BY month, program_office
ORDER BY month, monthly_spend DESC;


-- -------------------------------------------------------
-- Query 5: Running Total of Travel Spend Across the Year
-- Window function: SUM() OVER with ORDER BY month
-- Business use: Track cumulative spend against annual budget
-- -------------------------------------------------------
WITH monthly_totals AS (
    SELECT
        strftime('%Y-%m', travel_date)  AS month,
        ROUND(SUM(amount), 2)           AS monthly_spend
    FROM travel_expenses
    GROUP BY month
)
SELECT
    month,
    monthly_spend,
    ROUND(SUM(monthly_spend) OVER (
        ORDER BY month
    ), 2)                               AS cumulative_spend
FROM monthly_totals
ORDER BY month;


-- -------------------------------------------------------
-- Query 6: Employees Spending Above Their Office Average
-- CTE + window average to flag high spenders
-- Business use: Flag employees for travel policy review
-- -------------------------------------------------------
WITH office_avg AS (
    SELECT
        program_office,
        ROUND(AVG(amount), 2) AS office_avg_spend
    FROM travel_expenses
    GROUP BY program_office
),
employee_spend AS (
    SELECT
        te.employee_id,
        te.program_office,
        e.grade_level,
        ROUND(SUM(te.amount), 2)    AS total_spend,
        COUNT(*)                    AS trip_count,
        ROUND(AVG(te.amount), 2)    AS avg_per_trip
    FROM travel_expenses te
    JOIN employees e ON te.employee_id = e.employee_id
    GROUP BY te.employee_id, te.program_office, e.grade_level
)
SELECT
    es.employee_id,
    es.program_office,
    es.grade_level,
    es.total_spend,
    es.trip_count,
    es.avg_per_trip,
    oa.office_avg_spend,
    ROUND(es.avg_per_trip - oa.office_avg_spend, 2) AS variance_from_office_avg
FROM employee_spend es
JOIN office_avg oa ON es.program_office = oa.program_office
WHERE es.avg_per_trip > oa.office_avg_spend
ORDER BY variance_from_office_avg DESC
LIMIT 20;


-- -------------------------------------------------------
-- Query 7: Mileage Reimbursement Summary
-- How much is mileage costing and who is driving most?
-- Business use: Evaluate whether mileage reimbursement
--               costs justify alternatives (fleet vehicles, etc.)
-- -------------------------------------------------------
SELECT
    te.program_office,
    e.grade_level,
    COUNT(*)                            AS mileage_trips,
    ROUND(SUM(te.mileage), 1)           AS total_miles,
    ROUND(AVG(te.mileage), 1)           AS avg_miles_per_trip,
    ROUND(SUM(te.total_mileage_cost), 2) AS total_mileage_cost
FROM travel_expenses te
JOIN employees e ON te.employee_id = e.employee_id
WHERE te.expense_type = 'Mileage'
GROUP BY te.program_office, e.grade_level
ORDER BY total_mileage_cost DESC;


-- -------------------------------------------------------
-- Query 8: Travel Purpose Cost Comparison
-- Asset Management vs Asset Movement — which costs more?
-- Business use: Justify resource allocation between programs
-- -------------------------------------------------------
SELECT
    travel_purpose,
    expense_type,
    COUNT(*)                    AS trip_count,
    ROUND(SUM(amount), 2)       AS total_spend,
    ROUND(AVG(amount), 2)       AS avg_spend
FROM travel_expenses
GROUP BY travel_purpose, expense_type
ORDER BY travel_purpose, total_spend DESC;
