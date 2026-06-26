-- ============================================================
-- Federal Employee Travel Expense Analysis
-- Schema Setup
-- Author: Seentia Islam
-- ============================================================

CREATE TABLE IF NOT EXISTS employees (
    employee_id    TEXT PRIMARY KEY,
    name           TEXT,
    program_office TEXT,  -- Anonymized: actual office names withheld per clearance requirements
    grade_level    TEXT
);

CREATE TABLE IF NOT EXISTS travel_expenses (
    trip_id            TEXT PRIMARY KEY,
    employee_id        TEXT,
    program_office     TEXT,
    travel_date        DATE,
    travel_purpose     TEXT,  -- Generalized: sensitive program details withheld
    expense_type       TEXT,  -- Mileage | Ground Transportation | Air Transportation | Hotel/Lodging
    amount             REAL,
    mileage            REAL,  -- Populated only for Mileage expense type
    total_mileage_cost REAL,  -- Populated only for Mileage expense type
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
