--02_berka_data_validation.sql
--03_berka_sql_analysis.sql

-- ============================================
-- BERKA BANKING & FINANCIAL ANALYTICS
-- ============================================
-- File: 02_berka_data_validation.sql
-- Purpose: Check data quality and consistency
--          before starting the business analysis.
-- Status: In Progress
-- Version: 1.0
-- Date: 2026-09-08
-- ============================================

-- ============================================
-- 1. CHECK FOR MISSING VALUES
-- ============================================
-- Check each table for missing values in important columns.


-- District
-- Check for missing values in district information.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE district_name IS NULL) AS district_name_nulls,
    COUNT(*) FILTER (WHERE region IS NULL) AS region_nulls,
    COUNT(*) FILTER (WHERE inhabitants IS NULL) AS inhabitants_nulls,
    COUNT(*) FILTER (WHERE average_salary IS NULL) AS average_salary_nulls,
    COUNT(*) FILTER (WHERE unemployment_rate_1995 IS NULL) AS unemployment_1995_nulls,
    COUNT(*) FILTER (WHERE unemployment_rate_1996 IS NULL) AS unemployment_1996_nulls,
    COUNT(*) FILTER (WHERE crimes_1995 IS NULL) AS crimes_1995_nulls,
    COUNT(*) FILTER (WHERE crimes_1996 IS NULL) AS crimes_1996_nulls
FROM district;


-- Account
-- Check for missing values in account information.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE district_id IS NULL) AS district_id_nulls,
    COUNT(*) FILTER (WHERE frequency IS NULL) AS frequency_nulls,
    COUNT(*) FILTER (WHERE create_date IS NULL) AS create_date_nulls
FROM account;


-- Client
-- Check for missing values in customer information.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE birth_number IS NULL) AS birth_number_nulls,
    COUNT(*) FILTER (WHERE district_id IS NULL) AS district_id_nulls
FROM client;


-- Disposition
-- Check for missing values in customer-account relationships.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE client_id IS NULL) AS client_id_nulls,
    COUNT(*) FILTER (WHERE account_id IS NULL) AS account_id_nulls,
    COUNT(*) FILTER (WHERE disp_type IS NULL) AS disp_type_nulls
FROM disp;


-- Card
-- Check for missing values in card information.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE disp_id IS NULL) AS disp_id_nulls,
    COUNT(*) FILTER (WHERE card_type IS NULL) AS card_type_nulls,
    COUNT(*) FILTER (WHERE issued IS NULL) AS issued_nulls
FROM card;


-- Loan
-- Check for missing values in loan information.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE account_id IS NULL) AS account_id_nulls,
    COUNT(*) FILTER (WHERE grant_date IS NULL) AS grant_date_nulls,
    COUNT(*) FILTER (WHERE amount IS NULL) AS amount_nulls,
    COUNT(*) FILTER (WHERE duration IS NULL) AS duration_nulls,
    COUNT(*) FILTER (WHERE payments IS NULL) AS payments_nulls,
    COUNT(*) FILTER (WHERE status IS NULL) AS status_nulls
FROM loan;


-- Bank Order
-- Check for missing values in standing order information.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE account_id IS NULL) AS account_id_nulls,
    COUNT(*) FILTER (WHERE bank_to IS NULL) AS bank_to_nulls,
    COUNT(*) FILTER (WHERE account_to IS NULL) AS account_to_nulls,
    COUNT(*) FILTER (WHERE amount IS NULL) AS amount_nulls,
    COUNT(*) FILTER (WHERE k_symbol IS NULL) AS k_symbol_nulls
FROM bank_order;


-- Transactions
-- Check for missing values in transaction information.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE account_id IS NULL) AS account_id_nulls,
    COUNT(*) FILTER (WHERE trans_date IS NULL) AS trans_date_nulls,
    COUNT(*) FILTER (WHERE trans_type IS NULL) AS trans_type_nulls,
    COUNT(*) FILTER (WHERE operation IS NULL) AS operation_nulls,
    COUNT(*) FILTER (WHERE amount IS NULL) AS amount_nulls,
    COUNT(*) FILTER (WHERE balance IS NULL) AS balance_nulls,
    COUNT(*) FILTER (WHERE k_symbol IS NULL) AS k_symbol_nulls,
    COUNT(*) FILTER (WHERE bank IS NULL) AS bank_nulls,
    COUNT(*) FILTER (WHERE other_account IS NULL) AS other_account_nulls
FROM trans;


-- ============================================
-- 2. CHECK FOR DUPLICATE RECORDS
-- ============================================
-- Check each table for duplicate records.

-- District
-- Check for duplicate district records.
SELECT
    district_id,
    COUNT(*) AS duplicate_count
FROM district
GROUP BY district_id
HAVING COUNT(*) > 1;

-- Account
-- Check for duplicate account records.
SELECT
    account_id,
    COUNT(*) AS duplicate_count
FROM account
GROUP BY account_id
HAVING COUNT(*) > 1;

-- Client
-- Check for duplicate customer records.
SELECT
    client_id,
    COUNT(*) AS duplicate_count
FROM client
GROUP BY client_id
HAVING COUNT(*) > 1;

-- Disposition
-- Check for duplicate customer-account relationships.
SELECT
    disp_id,
    COUNT(*) AS duplicate_count
FROM disp
GROUP BY disp_id
HAVING COUNT(*) > 1;

-- Card
-- Check for duplicate card records.
SELECT
    card_id,
    COUNT(*) AS duplicate_count
FROM card
GROUP BY card_id
HAVING COUNT(*) > 1;

-- Loan
-- Check for duplicate loan records.
SELECT
    loan_id,
    COUNT(*) AS duplicate_count
FROM loan
GROUP BY loan_id
HAVING COUNT(*) > 1;

-- Bank Order
-- Check for duplicate standing order records.
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM bank_order
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Transactions
-- Check for duplicate transaction records.
SELECT
    trans_id,
    COUNT(*) AS duplicate_count
FROM trans
GROUP BY trans_id
HAVING COUNT(*) > 1;

-- ============================================
-- 3. CHECK PRIMARY KEY NULL VALUES
-- ============================================
-- Check that all primary key columns have values.
-- Primary keys should never be NULL.

-- District
-- Check for missing district IDs.
SELECT COUNT(*) AS null_primary_keys
FROM district
WHERE district_id IS NULL;

-- Account
-- Check for missing account IDs.
SELECT COUNT(*) AS null_primary_keys
FROM account
WHERE account_id IS NULL;

-- Client
-- Check for missing client IDs.
SELECT COUNT(*) AS null_primary_keys
FROM client
WHERE client_id IS NULL;

-- Disposition
-- Check for missing disposition IDs.
SELECT COUNT(*) AS null_primary_keys
FROM disp
WHERE disp_id IS NULL;

-- Card
-- Check for missing card IDs.
SELECT COUNT(*) AS null_primary_keys
FROM card
WHERE card_id IS NULL;

-- Loan
-- Check for missing loan IDs.
SELECT COUNT(*) AS null_primary_keys
FROM loan
WHERE loan_id IS NULL;

-- Bank Order
-- Check for missing order IDs.
SELECT COUNT(*) AS null_primary_keys
FROM bank_order
WHERE order_id IS NULL;

-- Transactions
-- Check for missing transaction IDs.
SELECT COUNT(*) AS null_primary_keys
FROM trans
WHERE trans_id IS NULL;

-- ============================================
-- 4. CHECK FOREIGN KEY RELATIONSHIPS
-- ============================================
-- Check that every foreign key points to an
-- existing record in the related parent table.

-- Account
-- Check for accounts linked to a district that does not exist.
SELECT COUNT(*) AS orphan_records
FROM account a
LEFT JOIN district d
    ON a.district_id = d.district_id
WHERE d.district_id IS NULL;

-- Client
-- Check for customers linked to a district that does not exist.
SELECT COUNT(*) AS orphan_records
FROM client c
LEFT JOIN district d
    ON c.district_id = d.district_id
WHERE d.district_id IS NULL;

-- Disposition
-- Check for customer relationships linked to a client that does not exist.
SELECT COUNT(*) AS orphan_records
FROM disp dp
LEFT JOIN client c
    ON dp.client_id = c.client_id
WHERE c.client_id IS NULL;

-- Disposition
-- Check for customer relationships linked to an account that does not exist.
SELECT COUNT(*) AS orphan_records
FROM disp dp
LEFT JOIN account a
    ON dp.account_id = a.account_id
WHERE a.account_id IS NULL;

-- Card
-- Check for cards linked to a disposition that does not exist.
SELECT COUNT(*) AS orphan_records
FROM card c
LEFT JOIN disp dp
    ON c.disp_id = dp.disp_id
WHERE dp.disp_id IS NULL;

-- Loan
-- Check for loans linked to an account that does not exist.
SELECT COUNT(*) AS orphan_records
FROM loan l
LEFT JOIN account a
    ON l.account_id = a.account_id
WHERE a.account_id IS NULL;

-- Bank Order
-- Check for orders linked to an account that does not exist.
SELECT COUNT(*) AS orphan_records
FROM bank_order bo
LEFT JOIN account a
    ON bo.account_id = a.account_id
WHERE a.account_id IS NULL;

-- Transactions
-- Check for transactions linked to an account that does not exist.
SELECT COUNT(*) AS orphan_records
FROM trans t
LEFT JOIN account a
    ON t.account_id = a.account_id
WHERE a.account_id IS NULL;

-- ============================================
-- 5. DATE CHECK
-- ============================================
-- Check date columns for invalid or unusual values
-- before using them in further analysis.

-- Account
-- Check account creation date range and invalid dates.
SELECT
    MIN(create_date) AS earliest_date,
    MAX(create_date) AS latest_date
FROM account;

SELECT create_date
FROM account
WHERE
    (create_date % 100) NOT BETWEEN 1 AND 31
    OR ((create_date / 100) % 100) NOT BETWEEN 1 AND 12;


-- Loan
-- Check loan grant date range and invalid dates.
SELECT
    MIN(grant_date) AS earliest_date,
    MAX(grant_date) AS latest_date
FROM loan;

SELECT grant_date
FROM loan
WHERE
    (grant_date % 100) NOT BETWEEN 1 AND 31
    OR ((grant_date / 100) % 100) NOT BETWEEN 1 AND 12;


-- Transactions
-- Check transaction date range and invalid dates.
SELECT
    MIN(trans_date) AS earliest_date,
    MAX(trans_date) AS latest_date
FROM trans;

SELECT trans_date
FROM trans
WHERE
    (trans_date % 100) NOT BETWEEN 1 AND 31
    OR ((trans_date / 100) % 100) NOT BETWEEN 1 AND 12;


-- Card
-- Check card issue date range.
-- The issued column is stored as text.
SELECT
    MIN(issued) AS earliest_date,
    MAX(issued) AS latest_date
FROM card;


-- Card
-- Check whether the card issue date has a valid
-- six-digit date portion and valid month/day values.
SELECT issued
FROM card
WHERE issued IS NOT NULL
  AND (
      LEFT(issued, 6) !~ '^[0-9]{6}$'
      OR SUBSTRING(issued, 3, 2)::INTEGER NOT BETWEEN 1 AND 12
      OR RIGHT(LEFT(issued, 6), 2)::INTEGER NOT BETWEEN 1 AND 31
  );


-- Client
-- Birth number contains date and gender information,
-- so it needs a separate validation check.
SELECT
    MIN(birth_number) AS smallest_birth_number,
    MAX(birth_number) AS largest_birth_number
FROM client;


-- Client
-- Check whether the encoded birth month is valid.
-- Female birth months are stored with 50 added to the month.
SELECT birth_number
FROM client
WHERE
    CASE
        WHEN ((birth_number / 100) % 100) > 50
            THEN ((birth_number / 100) % 100) - 50
        ELSE ((birth_number / 100) % 100)
    END NOT BETWEEN 1 AND 12;


-- Client
-- Check whether the encoded birth day is valid.
SELECT birth_number
FROM client
WHERE
    (birth_number % 100) NOT BETWEEN 1 AND 31;

-- ============================================
-- 6. NUMERIC VALUE CHECK
-- ============================================
-- Check numeric columns for negative, zero, or
-- otherwise suspicious values before using them
-- in further analysis.


-- ============================================
-- District
-- ============================================
-- Check population and other district measures
-- for negative or impossible values.

SELECT
    district_id,
    inhabitants,
    average_salary,
    urban_ratio,
    unemployment_rate_1995,
    unemployment_rate_1996,
    entrepreneurs_per_1000,
    crimes_1995,
    crimes_1996
FROM district
WHERE
    inhabitants < 0
    OR average_salary < 0
    OR urban_ratio < 0
    OR urban_ratio > 100
    OR unemployment_rate_1995 < 0
    OR unemployment_rate_1995 > 100
    OR unemployment_rate_1996 < 0
    OR unemployment_rate_1996 > 100
    OR entrepreneurs_per_1000 < 0
    OR crimes_1995 < 0
    OR crimes_1996 < 0;


-- District
-- Check whether municipality and city counts
-- contain negative values.
SELECT
    district_id,
    municipalities_less_500,
    municipalities_500_to_1999,
    municipalities_2000_to_9999,
    municipalities_10000_plus,
    cities
FROM district
WHERE
    municipalities_less_500 < 0
    OR municipalities_500_to_1999 < 0
    OR municipalities_2000_to_9999 < 0
    OR municipalities_10000_plus < 0
    OR cities < 0;


-- ============================================
-- Loan
-- ============================================
-- Check whether loan amounts, durations, and
-- monthly payments contain invalid values.

SELECT
    loan_id,
    amount,
    duration,
    payments
FROM loan
WHERE
    amount <= 0
    OR duration <= 0
    OR payments < 0;


-- ============================================
-- Bank Order
-- ============================================
-- Check whether order amounts are positive.
-- An order with zero or negative amount would
-- need further investigation.

SELECT
    order_id,
    amount
FROM bank_order
WHERE amount <= 0;


-- ============================================
-- Transactions
-- ============================================
-- Check whether transaction amounts contain
-- zero or negative values.
-- These results need to be interpreted together
-- with the transaction type and business meaning.

SELECT
    trans_id,
    account_id,
    trans_type,
    amount
FROM trans
WHERE amount <= 0;


-- Transactions
-- Check whether transaction balances are negative.
-- Negative balances are not automatically treated
-- as errors, so any results will be investigated
-- based on the account and transaction context.

SELECT
    trans_id,
    account_id,
    trans_date,
    trans_type,
    balance
FROM trans
WHERE balance < 0;


-- Transactions
-- Understand negative balances by transaction type.
SELECT
    trans_type,
    COUNT(*) AS transaction_count,
    MIN(balance) AS lowest_balance,
    MAX(balance) AS highest_negative_balance
FROM trans
WHERE balance < 0
GROUP BY trans_type
ORDER BY transaction_count DESC;


-- ============================================
-- NUMERIC VALUE SUMMARY
-- ============================================
-- Count potentially suspicious numeric values
-- so we can quickly understand the scale of any
-- issues found in the checks above.

SELECT
    COUNT(*) FILTER (WHERE amount <= 0) AS invalid_transaction_amounts,
    COUNT(*) FILTER (WHERE balance < 0) AS negative_transaction_balances
FROM trans;


-- ============================================
-- 7. CATEGORICAL VALUE CHECK
-- ============================================
-- Check categorical columns for unexpected or
-- inconsistent values before using them in analysis.


-- Account
-- Check the frequency values used when accounts
-- were created.
SELECT
    frequency,
    COUNT(*) AS account_count
FROM account
GROUP BY frequency
ORDER BY account_count DESC;


-- Disp
-- Check the types of account relationships.
SELECT
    disp_type,
    COUNT(*) AS relationship_count
FROM disp
GROUP BY disp_type
ORDER BY relationship_count DESC;


-- Card
-- Check the types of cards issued.
SELECT
    card_type,
    COUNT(*) AS card_count
FROM card
GROUP BY card_type
ORDER BY card_count DESC;


-- Loan
-- Check the loan status categories.
SELECT
    status,
    COUNT(*) AS loan_count
FROM loan
GROUP BY status
ORDER BY loan_count DESC;


-- Transactions
-- Check the main transaction types.
SELECT
    trans_type,
    COUNT(*) AS transaction_count
FROM trans
GROUP BY trans_type
ORDER BY transaction_count DESC;


-- Transactions
-- Check all operation categories.
SELECT
    operation,
    COUNT(*) AS transaction_count
FROM trans
GROUP BY operation
ORDER BY transaction_count DESC;


-- Transactions
-- Check all payment or transaction purpose
-- categories recorded in k_symbol.
SELECT
    k_symbol,
    COUNT(*) AS transaction_count
FROM trans
GROUP BY k_symbol
ORDER BY transaction_count DESC;


-- District
-- Check the regions represented in the district data.
SELECT
    region,
    COUNT(*) AS district_count
FROM district
GROUP BY region
ORDER BY district_count DESC;


-- ============================================
-- 8. RELATIONSHIP CONSISTENCY
-- ============================================
-- Check whether relationships between tables
-- are consistent with the business structure.


-- Account
-- Check whether every account has at least one
-- associated client relationship.
SELECT
    a.account_id
FROM account a
LEFT JOIN disp d
    ON a.account_id = d.account_id
WHERE d.account_id IS NULL;


-- Client
-- Check whether every client is associated with
-- at least one account relationship.
SELECT
    c.client_id
FROM client c
LEFT JOIN disp d
    ON c.client_id = d.client_id
WHERE d.client_id IS NULL;


-- Account
-- Check whether an account has more than one
-- OWNER relationship.
SELECT
    account_id,
    COUNT(*) AS owner_count
FROM disp
WHERE disp_type = 'OWNER'
GROUP BY account_id
HAVING COUNT(*) > 1
ORDER BY owner_count DESC;


-- Account
-- Check whether an account has multiple
-- DISPONENT relationships.
SELECT
    account_id,
    COUNT(*) AS disponent_count
FROM disp
WHERE disp_type = 'DISPONENT'
GROUP BY account_id
HAVING COUNT(*) > 1
ORDER BY disponent_count DESC;


-- Card
-- Check whether a card is linked to a valid
-- account through its disposition relationship.
SELECT
    c.card_id,
    d.account_id
FROM card c
JOIN disp d
    ON c.disp_id = d.disp_id
WHERE d.account_id IS NULL;


-- Loan
-- Check whether an account has multiple loans
-- and understand the relationship.
SELECT
    account_id,
    COUNT(*) AS loan_count
FROM loan
GROUP BY account_id
HAVING COUNT(*) > 1
ORDER BY loan_count DESC;


-- Transactions
-- Check whether every account with transactions
-- has a corresponding account record.
SELECT
    t.account_id,
    COUNT(*) AS transaction_count
FROM trans t
LEFT JOIN account a
    ON t.account_id = a.account_id
WHERE a.account_id IS NULL
GROUP BY t.account_id;


-- Bank Orders
-- Check whether every order belongs to a valid account.
SELECT
    o.account_id,
    COUNT(*) AS order_count
FROM bank_order o
LEFT JOIN account a
    ON o.account_id = a.account_id
WHERE a.account_id IS NULL
GROUP BY o.account_id;


-- ============================================
-- 9. DATASET-SPECIFIC ISSUES
-- ============================================
-- Investigate unusual patterns or issues that
-- are specific to the Berka dataset.


-- Client
-- Check whether multiple clients share the same
-- birth number, which may be possible because the
-- value represents encoded birth information.
SELECT
    birth_number,
    COUNT(*) AS client_count
FROM client
GROUP BY birth_number
HAVING COUNT(*) > 1
ORDER BY client_count DESC;


-- Account
-- Check whether account creation dates fall within
-- a reasonable range for the dataset.
SELECT
    MIN(create_date) AS earliest_account_date,
    MAX(create_date) AS latest_account_date
FROM account;


-- Loan
-- Check whether loan grant dates fall within the
-- period covered by the account data.
SELECT
    MIN(grant_date) AS earliest_loan_date,
    MAX(grant_date) AS latest_loan_date
FROM loan;


-- Transactions
-- Check whether transaction dates fall within the
-- overall account and loan activity period.
SELECT
    MIN(trans_date) AS earliest_transaction_date,
    MAX(trans_date) AS latest_transaction_date
FROM trans;


-- Card
-- Check whether card issue dates fall within the
-- period represented by the dataset.
SELECT
    MIN(issued) AS earliest_card_issue,
    MAX(issued) AS latest_card_issue
FROM card;


-- Loan
-- Check whether loan duration and monthly payment
-- are consistent with the total loan amount.
SELECT
    loan_id,
    amount,
    duration,
    payments,
    ROUND(amount / NULLIF(duration, 0), 2) AS expected_payment
FROM loan
WHERE payments <> ROUND(amount / NULLIF(duration, 0), 2);


-- Account
-- Check whether accounts have multiple owners,
-- which would be unusual for the main account holder
-- relationship.
SELECT
    account_id,
    COUNT(*) AS owner_count
FROM disp
WHERE disp_type = 'OWNER'
GROUP BY account_id
HAVING COUNT(*) > 1
ORDER BY owner_count DESC;



-- ============================================
-- 10. VALIDATION SUMMARY
-- ============================================
-- Record the important data-quality findings,
-- their impact, and the decision taken for
-- each finding.

-- DATA QUALITY FINDINGS
--
-- 1. District
--    - unemployment_rate_1995: 1 NULL value
--    - crimes_1995: 1 NULL value
--    - Source: original dataset contains '?'
--    - Impact: Affects a small number of district-level
--      records and may affect related regional analysis.
--    - Treatment: Kept as SQL NULL; handle appropriately
--      during analysis.
--
-- 2. Transactions
--    - k_symbol: 481,881 NULL values
--    - bank: 782,812 NULL values
--    - other_account: 760,931 NULL values
--    - Impact: These columns have substantial missing data
--      and may affect transaction-level analysis involving
--      payment purpose or counterparty information.
--    - Treatment: Kept as SQL NULL; investigate business
--      meaning before using these columns.
--
-- 3. Transactions
--    - 53,433 blank-space values found in k_symbol.
--    - Impact: Blank values are different from SQL NULL
--      and may represent an unspecified transaction category.
--    - Treatment: Flagged for further investigation.
--
-- 4. Transactions
--    - 14 transactions have amount = 0.00.
--    - No negative transaction amounts were found.
--    - Impact: Zero-value transactions may require
--      business-context investigation.
--    - Treatment: Flagged for investigation; not treated
--      as confirmed data-quality errors.
--
-- 5. Transaction Balances
--    - 2,999 transactions have negative balances.
--    - Negative balances occur across VYDAJ, PRIJEM,
--      and VYBER transactions.
--    - Impact: May represent valid business conditions
--      such as overdraft.
--    - Treatment: Not treated as a confirmed data-quality
--      error; interpret according to business context.
--
-- 6. Other Validation Checks
--    - No duplicate primary-key values found.
--    - No NULL primary keys found.
--    - No orphan foreign-key relationships found.
--    - No relationship consistency issues found.
--    - No invalid date patterns were identified.
--    - No confirmed invalid categorical values were identified.
--    - No inconsistent loan amount, duration, and payment
--      relationships were found.
--    - No accounts with multiple OWNER relationships were found.
--
-- Overall Decision
--    - No records were removed or modified during validation.
--    - Identified issues have been documented and will be
--      considered during the SQL analysis stage.
--    - The dataset is suitable for proceeding to business
--      analysis with the documented flags in mind.


-- ============================================
-- VALIDATION COMPLETE
-- ============================================
-- Data-quality checks have been completed.
-- Important findings and investigation flags have
-- been documented.
-- No source records were modified or removed.
-- Next step: Run 03_berka_sql_analysis.sql
-- ============================================


