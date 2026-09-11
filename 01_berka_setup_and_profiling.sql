/* ============================================================
   PROJECT       : Berka Banking & Financial Analytics
   DATASET       : PKDD '99 / Berka Financial Dataset
   FILE          : 01_berka_setup_and_profiling.sql
   PURPOSE       : Create the Berka database structure, define
                   tables and relationships, import source data,
                   verify successful loading, and perform
                   initial data profiling.
   STATUS        : In Progress
   VERSION       : 1.0
   DATE          : 2026-09-08
   AUTHOR        : Adeeb Muzaffar
=================  ============================================================ */

--- ============================================
-- 1. DISTRICT TABLE
-- ============================================
-- Stores basic information about each district,
-- including population, salary, unemployment, and crime data.
-- Primary key: district_id
-- Purpose: Used to connect regional information with customers
-- and accounts for further analysis.

CREATE TABLE district (
    district_id INTEGER PRIMARY KEY,
    district_name VARCHAR(19),
    region VARCHAR(15),
    inhabitants INTEGER,
    municipalities_less_500 INTEGER,
    municipalities_500_to_1999 INTEGER,
    municipalities_2000_to_9999 INTEGER,
    municipalities_10000_plus INTEGER,
    cities INTEGER,
    urban_ratio NUMERIC(5,2),
    average_salary NUMERIC(10,2),
    unemployment_rate_1995 NUMERIC(5,2),
    unemployment_rate_1996 NUMERIC(5,2),
    entrepreneurs_per_1000 INTEGER,
    crimes_1995 INTEGER,
    crimes_1996 INTEGER
);

-- ============================================
-- 2. ACCOUNT TABLE
-- ============================================
-- Stores the basic details of each bank account,
-- including the district, account frequency, and creation date.
-- Primary key: account_id
-- Foreign key: district_id → district
-- Purpose: Main account-level table used throughout the project.

CREATE TABLE account (
    account_id INTEGER PRIMARY KEY,
    district_id INTEGER,
    frequency VARCHAR(18),
    create_date INTEGER,

    CONSTRAINT fk_account_district
        FOREIGN KEY (district_id)
        REFERENCES district(district_id)
);

-- ============================================
-- 3. CLIENT TABLE
-- ============================================
-- Stores basic information about each bank customer,
-- including their birth number and district.
-- Primary key: client_id
-- Foreign key: district_id → district
-- Purpose: Used to analyze customer demographics and link
-- customers to their accounts.

CREATE TABLE client (
    client_id INTEGER PRIMARY KEY,
    birth_number INTEGER,
    district_id INTEGER,

    CONSTRAINT fk_client_district
        FOREIGN KEY (district_id)
        REFERENCES district
);
		
-- ============================================
-- 4. DISP TABLE
-- ============================================
-- Links customers to their bank accounts and shows
-- whether they are the owner or a secondary user.
-- Primary key: disp_id
-- Foreign keys: client_id → client, account_id → account
-- Purpose: Used to understand account ownership and
-- customer-account relationships.

CREATE TABLE disp (
    disp_id INTEGER PRIMARY KEY,
    client_id INTEGER,
    account_id INTEGER,
    disp_type VARCHAR(9),

    CONSTRAINT fk_disp_client
        FOREIGN KEY (client_id)
        REFERENCES client(client_id),

    CONSTRAINT fk_disp_account
        FOREIGN KEY (account_id)
        REFERENCES account(account_id)
);

-- ============================================
-- 5. CARD TABLE
-- ============================================
-- Stores information about cards issued to customers,
-- including card type and issue date.
-- Primary key: card_id
-- Foreign key: disp_id → disp
-- Purpose: Used to analyze card ownership and card types.

CREATE TABLE card (
    card_id INTEGER PRIMARY KEY,
    disp_id INTEGER,
    card_type VARCHAR(7),
    issued VARCHAR(20),

    CONSTRAINT fk_card_disp
        FOREIGN KEY (disp_id)
        REFERENCES disp(disp_id)
);

-- ============================================
-- 6. LOAN TABLE
-- ============================================
-- Stores loan details such as amount, duration,
-- monthly payments, and repayment status.
-- Primary key: loan_id
-- Foreign key: account_id → account
-- Purpose: Used for loan portfolio and repayment analysis.

CREATE TABLE loan (
    loan_id INTEGER PRIMARY KEY,
    account_id INTEGER,
    grant_date INTEGER,
    amount NUMERIC(12,2),
    duration INTEGER,
    payments NUMERIC(12,2),
    status CHAR(1),

    CONSTRAINT fk_loan_account
        FOREIGN KEY (account_id)
        REFERENCES account(account_id)
);

-- ============================================
-- 7. BANK_ORDER TABLE
-- ============================================
-- Stores standing orders linked to bank accounts,
-- including payment amount and payment category.
-- Primary key: order_id
-- Foreign key: account_id → account
-- Purpose: Used to analyze recurring payments and
-- spending by category.

CREATE TABLE bank_order (
    order_id INTEGER PRIMARY KEY,
    account_id INTEGER,
    bank_to VARCHAR(2),
    account_to BIGINT,
    amount NUMERIC(12,2),
    k_symbol VARCHAR(8),

    CONSTRAINT fk_bank_order_account
        FOREIGN KEY (account_id)
        REFERENCES account(account_id)
);

-- ============================================
-- 8. TRANS TABLE
-- ============================================
-- Stores individual transactions made through bank accounts,
-- including transaction type, amount, balance, and date.
-- Primary key: trans_id
-- Foreign key: account_id → account
-- Purpose: Main transaction table used to analyze
-- customer activity, cash flow, and account balances.

CREATE TABLE trans (
    trans_id INTEGER PRIMARY KEY,
    account_id INTEGER,
    trans_date INTEGER,
    trans_type VARCHAR(6),
    operation VARCHAR(14),
    amount NUMERIC(12,2),
    balance NUMERIC(12,2),
    k_symbol VARCHAR(11),
    bank VARCHAR(3),
    other_account BIGINT,

    CONSTRAINT fk_trans_account
        FOREIGN KEY (account_id)
        REFERENCES account(account_id)
);

-- ============================================
-- CREATE INDEXES
-- ============================================
-- Add indexes to columns that are frequently used
-- for joins, filtering, and transaction analysis.

-- Account indexes
CREATE INDEX idx_account_district_id
ON account(district_id);


-- Client indexes
CREATE INDEX idx_client_district_id
ON client(district_id);


-- Disposition indexes
CREATE INDEX idx_disp_client_id
ON disp(client_id);

CREATE INDEX idx_disp_account_id
ON disp(account_id);


-- Card indexes
CREATE INDEX idx_card_disp_id
ON card(disp_id);


-- Loan indexes
CREATE INDEX idx_loan_account_id
ON loan(account_id);


-- Bank order indexes
CREATE INDEX idx_bank_order_account_id
ON bank_order(account_id);


-- Transaction indexes
CREATE INDEX idx_trans_account_id
ON trans(account_id);

CREATE INDEX idx_trans_date
ON trans(trans_date);

CREATE INDEX idx_trans_account_date
ON trans(account_id, trans_date);

-- ============================================
-- VERIFY ALL TABLES CREATED
-- ============================================
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- ============================================
-- CHECK ROW COUNTS
-- ============================================
SELECT 'district' AS table_name, COUNT(*) AS row_count FROM district
UNION ALL
SELECT 'account', COUNT(*) FROM account
UNION ALL
SELECT 'client', COUNT(*) FROM client
UNION ALL
SELECT 'disp', COUNT(*) FROM disp
UNION ALL
SELECT 'card', COUNT(*) FROM card
UNION ALL
SELECT 'loan', COUNT(*) FROM loan
UNION ALL
SELECT 'bank_order', COUNT(*) FROM bank_order
UNION ALL
SELECT 'trans', COUNT(*) FROM trans
ORDER BY table_name;

-- ============================================
-- SETUP COMPLETE
-- ============================================
-- All 8 tables created and loaded successfully.
-- Row counts have been checked against the source files.
-- Next step: Run 02_berka_data_validation.sql
-- ============================================