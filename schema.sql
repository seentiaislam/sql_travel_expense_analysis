-- ============================================================
-- Financial Transaction Analytics
-- Schema Setup
-- Author: Seentia Islam
-- ============================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id   TEXT PRIMARY KEY,
    name          TEXT,
    age           INTEGER,
    state         TEXT,
    credit_limit  REAL
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id   TEXT PRIMARY KEY,
    customer_id      TEXT,
    transaction_date DATE,
    merchant         TEXT,
    category         TEXT,
    amount           REAL,
    state            TEXT,
    is_fraud         INTEGER,  -- 0 = legitimate, 1 = flagged fraud
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
