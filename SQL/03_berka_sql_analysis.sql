-- ============================================
-- BERKA BANKING & FINANCIAL ANALYTICS
-- ============================================
-- File: 03_berka_sql_analysis.sql
-- Purpose: Perform business-focused SQL analysis
--          on the validated Berka dataset.
-- Status: In Progress
-- Version: 1.0
-- Date: 2026-09-09
-- ============================================

-- ============================================
-- BUSINESS ANALYSIS PIPELINE
-- ============================================
-- Q1. Customer Demographics & Acquisition
-- Q2. Account Ownership & Secondary Users
-- Q3. Customer Transactional Activity
-- Q4. 30-Day Moving Average Balance
-- Q5. Transaction Volume & Monetary Analysis
-- Q6. Standing Order Payment Analysis
-- Q7. Loan Portfolio & Repayment Status
-- Q8. Debt-Service Burden
-- Q9. Regional Financial & Loan Analysis
-- Q10. Card Tier Analysis
-- ============================================

/*
 * Question 1: Customer Demographics & Acquisition
 * ----------------------------------------------------------------------------
 * What we're trying to analyze here:
 * - Understand the age and gender profile of customers associated with bank accounts.
 * - Decode the birth_number field to derive birth information and gender.
 * - Calculate customer age from the birth year.
 * - Group customers into age cohorts: under 30, 30–50, and 50+.
 * - Connect customers with their account relationships to understand
 *   the demographic composition of the bank's customer base.
 * - Calculate the number and percentage of unique customers in each age group.
 * - Compare the demographic distribution across age groups and gender.
 */

-- ============================================
-- Q1. CUSTOMER DEMOGRAPHICS & ACQUISITION
-- ============================================


-- ------------------------------------------------
-- Step 1: Decode the birth_number and identify gender
-- ------------------------------------------------
-- The birth_number stores birth information as YYMMDDSSSC.
-- For females, 50 is added to the birth month.
WITH customer_details AS (

    SELECT
        client_id,
        birth_number,

        -- Extract the two-digit birth year.
        FLOOR(birth_number / 10000)::INTEGER AS birth_year,

        -- Extract the encoded birth month.
        ((birth_number / 100) % 100)::INTEGER AS encoded_month,

        -- Identify gender from the encoded birth month.
        CASE
            WHEN ((birth_number / 100) % 100)::INTEGER BETWEEN 51 AND 62
                THEN 'Female'
            WHEN ((birth_number / 100) % 100)::INTEGER BETWEEN 1 AND 12
                THEN 'Male'
            ELSE 'Unknown'
        END AS gender

    FROM client
),


-- ------------------------------------------------
-- Step 2: Convert the encoded month and calculate age
-- ------------------------------------------------
-- For females, subtract 50 from the encoded month
-- to get the actual birth month.
customer_age AS (

    SELECT
        client_id,
        birth_number,
        birth_year,
        gender,

        CASE
            WHEN encoded_month BETWEEN 51 AND 62
                THEN encoded_month - 50
            ELSE encoded_month
        END AS birth_month,

        -- Convert the two-digit year into the four-digit birth year.
        CASE
            WHEN birth_year >= 0 AND birth_year <= 20
                THEN 2000 + birth_year
            ELSE 1900 + birth_year
        END AS full_birth_year

    FROM customer_details
),


-- ------------------------------------------------
-- Step 3: Calculate age and create age groups
-- ------------------------------------------------
-- Calculate the customer's approximate age and place them
-- into the age groups used for the analysis.
customer_demographics AS (

    SELECT
        client_id,
        gender,
        full_birth_year,

        -- Calculate approximate age using the current year.
        EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER - full_birth_year AS age,

        -- Group customers into the required age cohorts.
        CASE
            WHEN EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER - full_birth_year < 30
                THEN 'Under 30'
            WHEN EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER - full_birth_year BETWEEN 30 AND 50
                THEN '30-50'
            ELSE '50+'
        END AS age_group

    FROM customer_age
),


-- ------------------------------------------------
-- Step 4: Connect customers with their accounts
-- ------------------------------------------------
-- Connect customers to their accounts through the disp table.
-- DISTINCT keeps each customer-account relationship only once.
customer_accounts AS (

    SELECT DISTINCT
        cd.client_id,
        d.account_id,
        cd.gender,
        cd.full_birth_year,
        cd.age,
        cd.age_group

    FROM customer_demographics cd

    JOIN disp d
        ON cd.client_id = d.client_id

    JOIN account a
        ON d.account_id = a.account_id
)


-- ------------------------------------------------
-- Step 5: Summarize customers by age group
-- ------------------------------------------------
-- Count unique customers in each age group and calculate
-- their percentage of the total customer base.
SELECT
    age_group,
    COUNT(DISTINCT client_id) AS customer_count,

    ROUND(
        COUNT(DISTINCT client_id) * 100.0
        / SUM(COUNT(DISTINCT client_id)) OVER (),
        2
    ) AS percentage

FROM customer_accounts

GROUP BY
    age_group

ORDER BY
    CASE
        WHEN age_group = 'Under 30' THEN 1
        WHEN age_group = '30-50' THEN 2
        WHEN age_group = '50+' THEN 3
    END;

/*
 * Question 2: Account Ownership & Secondary Users
 * ----------------------------------------------------------------------------
 * What we're trying to analyze here:
 * - Understand how customers are associated with bank accounts.
 * - Identify accounts that have a secondary user (DISPONENT).
 * - Separate single-owner accounts from accounts with secondary users.
 * - Compare the number of accounts and average balances across these groups.
 * - Understand whether accounts with secondary users have a different
 *   balance profile from single-owner accounts.
 */

-- ============================================
-- Q2. ACCOUNT OWNERSHIP & SECONDARY USERS
-- ============================================


-- ------------------------------------------------
-- Step 1: Identify the number of owners and secondary users
-- ------------------------------------------------
-- Count the different types of customer relationships for each account.
WITH account_relationships AS (

    SELECT
        account_id,

        -- Count the primary owners linked to each account.
        COUNT(*) FILTER (
            WHERE disp_type = 'OWNER'
        ) AS owner_count,

        -- Count the secondary users linked to each account.
        COUNT(*) FILTER (
            WHERE disp_type = 'DISPONENT'
        ) AS secondary_user_count

    FROM disp

    GROUP BY
        account_id
),


-- ------------------------------------------------
-- Step 2: Classify accounts by ownership structure
-- ------------------------------------------------
-- Separate accounts with only an owner from accounts
-- that also have at least one secondary user.
account_types AS (

    SELECT
        account_id,
        owner_count,
        secondary_user_count,

        CASE
            WHEN secondary_user_count > 0
                THEN 'Has Secondary User'
            ELSE 'Single Owner'
        END AS account_type

    FROM account_relationships
),


-- ------------------------------------------------
-- Step 3: Connect account type with account balance
-- ------------------------------------------------
-- Join the account classification with account transaction data.
-- The latest transaction balance is used as the account's current balance.
account_balances AS (

    SELECT
        at.account_id,
        at.account_type,
        t.balance

    FROM account_types at

    JOIN LATERAL (
        SELECT
            balance
        FROM trans
        WHERE trans.account_id = at.account_id
        ORDER BY trans_date DESC, trans_id DESC
        LIMIT 1
    ) t
        ON TRUE
)


-- ------------------------------------------------
-- Step 4: Compare account groups
-- ------------------------------------------------
-- Count accounts and calculate the average latest balance
-- for each ownership group.
SELECT
    account_type,
    COUNT(DISTINCT account_id) AS account_count,
    ROUND(
        AVG(balance),
        2
    ) AS average_balance

FROM account_balances

GROUP BY
    account_type

ORDER BY
    account_type;


/*
 * Question 3: Customer Transactional Activity
 * ----------------------------------------------------------------------------
 * What we're trying to analyze here:
 * - Understand how active each account is based on its transaction history.
 * - Identify the most recent transaction for each account.
 * - Measure transaction frequency for each account.
 * - Calculate the average balance maintained by each account.
 * - Calculate total inflows received by each account.
 * - Create basic activity metrics that can be used for further customer
 *   segmentation and financial analysis.
 */

-- ============================================
-- Q3. CUSTOMER TRANSACTIONAL ACTIVITY
-- ============================================


-- ------------------------------------------------
-- Step 1: Find the latest transaction date
-- ------------------------------------------------
-- Find the most recent transaction for each account
-- to understand how recently the account was active.
WITH account_activity AS (

    SELECT
        account_id,

        MAX(trans_date) AS last_transaction_date,

        -- Count the number of transactions made by each account.
        COUNT(*) AS transaction_count,

        -- Calculate the average balance recorded across transactions.
        ROUND(
            AVG(balance),
            2
        ) AS average_balance,

        -- Calculate the total amount received by each account.
        SUM(
            CASE
                WHEN trans_type = 'PRIJEM'
                    THEN amount
                ELSE 0
            END
        ) AS total_inflows

    FROM trans

    GROUP BY
        account_id
)


-- ------------------------------------------------
-- Step 2: Show the account activity metrics
-- ------------------------------------------------
-- Return one row per account with its main transaction activity measures.
SELECT
    account_id,
    last_transaction_date,
    transaction_count,
    average_balance,
    total_inflows

FROM account_activity

ORDER BY
    account_id;


/*
 * Question 4: 30-Day Moving Average Balance
 * ----------------------------------------------------------------------------
 * What we're trying to analyze here:
 * - Understand how an account's balance changes over time.
 * - Calculate the average balance over the previous 30 calendar days.
 * - Smooth short-term balance fluctuations to identify recent balance trends.
 * - Compare an account's actual balance with its recent 30-day average.
 */

-- ============================================
-- Q4. 30-DAY MOVING AVERAGE BALANCE
-- ============================================

-- Step 1: Convert the YYMMDD transaction date into a proper PostgreSQL DATE.
WITH transaction_dates AS (
    SELECT
        trans_id,
        account_id,
        TO_DATE(trans_date::TEXT, 'YYMMDD') AS transaction_date,
        balance
    FROM trans
),

-- Step 2: Calculate the 30-day moving average for each account.
moving_average AS (
    SELECT
        trans_id,
        account_id,
        transaction_date,
        balance,
        ROUND(
            AVG(balance) OVER (
                PARTITION BY account_id
                ORDER BY transaction_date
                RANGE BETWEEN INTERVAL '30 days' PRECEDING
                      AND CURRENT ROW
            ),
            2
        ) AS moving_avg_30_days
    FROM transaction_dates
)

-- Step 3: Display the actual balance alongside the 30-day moving average.
SELECT
    account_id,
    transaction_date,
    balance,
    moving_avg_30_days
FROM moving_average
ORDER BY
    account_id,
    transaction_date,
    trans_id;


/*
 * Question 5: Transaction Volume & Monetary Analysis
 * ----------------------------------------------------------------------------
 * What we're trying to analyze here:
 * - Understand the volume of major transaction activities in the bank.
 * - Compare how frequently Cash Deposits, Wire Transfers, and Card Withdrawals occur.
 * - Calculate the total monetary amount associated with each transaction category.
 * - Calculate each transaction category's share of the total transaction volume.
 * - Calculate each transaction category's share of the total monetary amount.
 * - Compare transaction frequency with monetary value to understand which
 *   activities are most frequent and which involve the highest amount of money.
 */

-- ============================================
-- Q5. TRANSACTION VOLUME & MONETARY ANALYSIS
-- ============================================

-- Step 1: Group the raw transaction operations into business-friendly categories.
WITH transaction_categories AS (
    SELECT
        trans_id,
        amount,
        CASE
            WHEN operation = 'VKLAD'
                THEN 'Cash Deposit'

            WHEN operation IN ('PREVOD NA UCET', 'PREVOD Z UCTU')
                THEN 'Wire Transfer'

            WHEN operation = 'VYBER KARTOU'
                THEN 'Card Withdrawal'
        END AS transaction_category
    FROM trans
),

-- Step 2: Keep only the three transaction categories we want to analyze.
selected_transactions AS (
    SELECT
        trans_id,
        amount,
        transaction_category
    FROM transaction_categories
    WHERE transaction_category IS NOT NULL
),

-- Step 3: Calculate transaction count and total monetary amount for each category.
transaction_summary AS (
    SELECT
        transaction_category,
        COUNT(*) AS transaction_count,
        ROUND(SUM(amount), 2) AS total_amount
    FROM selected_transactions
    GROUP BY transaction_category
)

-- Step 4: Calculate both transaction share and monetary share for each category.
SELECT
    transaction_category,
    transaction_count,

    -- Show how much of the total transaction volume belongs to this category.
    ROUND(
        transaction_count * 100.0
        / SUM(transaction_count) OVER (),
        2
    ) AS transaction_percentage,

    total_amount,

    -- Show how much of the total monetary amount belongs to this category.
    ROUND(
        total_amount * 100.0
        / SUM(total_amount) OVER (),
        2
    ) AS amount_percentage

FROM transaction_summary

-- Show the most frequently occurring transaction categories first.
ORDER BY transaction_count DESC;


/*
 * Question 6: Standing Order Payment Analysis
 * ----------------------------------------------------------------------------
 * What we're trying to analyze here:
 * - Understand the types of payments made through standing orders.
 * - Group standing orders by their payment category using k_symbol.
 * - Calculate how many standing orders belong to each payment category.
 * - Calculate the total payment amount for each category.
 * - Calculate each category's share of the total standing-order payment amount.
 * - Identify which payment categories contribute the most to overall
 *   standing-order payment activity.
 */

-- ============================================
-- Q6. STANDING ORDER PAYMENT ANALYSIS
-- ============================================

-- Step 1: Select the payment information needed for the analysis.
WITH standing_order_data AS (
    SELECT
        order_id,
        amount,
        k_symbol
    FROM bank_order
),

-- Step 2: Calculate the number of orders and total payment amount for each category.
payment_summary AS (
    SELECT
        k_symbol,
        COUNT(*) AS payment_count,
        ROUND(SUM(amount), 2) AS total_payment
    FROM standing_order_data
    GROUP BY k_symbol
)

-- Step 3: Calculate each category's share of the total standing-order payment amount.
SELECT
    k_symbol,
    payment_count,
    total_payment,
    ROUND(
        total_payment * 100.0
        / SUM(total_payment) OVER (),
        2
    ) AS payment_percentage
FROM payment_summary

-- Show the categories with the highest total payment first.
ORDER BY total_payment DESC;


/*
 * Question 7: Loan Portfolio & Repayment Status
 * ----------------------------------------------------------------------------
 * What we're trying to analyze here:
 * - Understand the overall size of the bank's loan portfolio.
 * - Count the number of loans in each repayment-status category.
 * - Calculate the total loan amount associated with each status.
 * - Calculate each status category's share of the total number of loans.
 * - Calculate each status category's share of the total loan amount.
 * - Compare loan volume with monetary exposure to identify which
 *   repayment-status categories represent the largest portion of the
 *   bank's loan portfolio.
 */

-- ============================================
-- Q7. LOAN PORTFOLIO & REPAYMENT STATUS
-- ============================================

-- Step 1: Select the loan information needed for the analysis.
WITH loan_data AS (
    SELECT
        loan_id,
        amount,
        status
    FROM loan
),

-- Step 2: Calculate the number of loans and total loan amount for each status.
loan_summary AS (
    SELECT
        status,
        COUNT(*) AS loan_count,
        ROUND(SUM(amount), 2) AS total_loan_amount
    FROM loan_data
    GROUP BY status
)

-- Step 3: Calculate both loan share and monetary exposure share for each status.
SELECT
    status,
    loan_count,

    -- Show each status category's share of the total number of loans.
    ROUND(
        loan_count * 100.0
        / SUM(loan_count) OVER (),
        2
    ) AS loan_percentage,

    total_loan_amount,

    -- Show each status category's share of the total loan amount.
    ROUND(
        total_loan_amount * 100.0
        / SUM(total_loan_amount) OVER (),
        2
    ) AS amount_percentage

FROM loan_summary

-- Show the status categories with the largest loan amount first.
ORDER BY total_loan_amount DESC;


/*
 * Question 8: Debt-Service Burden
 * ----------------------------------------------------------------------------
 * What we're trying to analyze here:
 * - Understand how large a borrower's monthly loan payment is compared
 *   with their average monthly account inflow.
 * - Calculate each borrower's monthly inflow from PRIJEM transactions.
 * - Calculate the 12-month average monthly inflow for each account.
 * - Compare the monthly loan payment with the borrower's average monthly inflow.
 * - Calculate the Debt-Service Burden ratio to understand the relative
 *   repayment burden on borrowers.
 */

-- ============================================
-- Q8. DEBT-SERVICE BURDEN
-- ============================================

-- Step 1: Convert the transaction date into a proper PostgreSQL date
-- so we can group transactions by month.
WITH transaction_dates AS (
    SELECT
        account_id,
        TO_DATE(trans_date::TEXT, 'YYMMDD') AS transaction_date,
        amount,
        trans_type
    FROM trans
),

-- Step 2: Calculate the total money received by each account in each month.
-- PRIJEM represents money coming into the account.
monthly_inflows AS (
    SELECT
        account_id,
        DATE_TRUNC('month', transaction_date)::DATE AS month,
        SUM(
            CASE
                WHEN trans_type = 'PRIJEM' THEN amount
                ELSE 0
            END
        ) AS monthly_inflow
    FROM transaction_dates
    GROUP BY
        account_id,
        DATE_TRUNC('month', transaction_date)
),

-- Step 3: Calculate the 12-month rolling average of monthly inflows.
-- RANGE is used because we want a calendar-based time window.
rolling_inflows AS (
    SELECT
        account_id,
        month,
        monthly_inflow,
        ROUND(
            AVG(monthly_inflow) OVER (
                PARTITION BY account_id
                ORDER BY month
                RANGE BETWEEN INTERVAL '12 months' PRECEDING
                      AND CURRENT ROW
            ),
            2
        ) AS avg_monthly_inflow_12_months
    FROM monthly_inflows
),

-- Step 4: Find the most recent available monthly inflow for each account.
-- This gives us the latest 12-month average available in the dataset.
latest_inflow AS (
    SELECT
        account_id,
        month,
        avg_monthly_inflow_12_months
    FROM (
        SELECT
            account_id,
            month,
            avg_monthly_inflow_12_months,
            ROW_NUMBER() OVER (
                PARTITION BY account_id
                ORDER BY month DESC
            ) AS row_num
        FROM rolling_inflows
    ) ranked_inflows
    WHERE row_num = 1
),

-- Step 5: Connect each loan with the account's latest 12-month
-- average monthly inflow.
loan_burden AS (
    SELECT
        l.loan_id,
        l.account_id,
        l.payments AS monthly_loan_payment,
        li.avg_monthly_inflow_12_months
    FROM loan l
    JOIN latest_inflow li
        ON l.account_id = li.account_id
    WHERE l.status IN ('C', 'D')
)

-- Step 6: Calculate the Debt-Service Burden ratio.
SELECT
    loan_id,
    account_id,
    ROUND(monthly_loan_payment, 2) AS monthly_loan_payment,
    ROUND(avg_monthly_inflow_12_months, 2) AS avg_monthly_inflow_12_months,
    ROUND(
        monthly_loan_payment
        / NULLIF(avg_monthly_inflow_12_months, 0),
        4
    ) AS debt_service_burden_ratio,
    ROUND(
        monthly_loan_payment * 100.0
        / NULLIF(avg_monthly_inflow_12_months, 0),
        2
    ) AS debt_service_burden_percentage
FROM loan_burden

-- Show borrowers with the highest payment burden first.
ORDER BY debt_service_burden_percentage DESC;


/*
 * Question 9: Regional Financial & Loan Analysis
 * ----------------------------------------------------------------------------
 * What we're trying to analyze here:
 * - Compare financial conditions across districts.
 * - Examine district-level average salary and unemployment rates.
 * - Compare these regional indicators with average account balances.
 * - Analyze loan activity and repayment-status distribution by district.
 * - Identify districts where regional economic conditions and loan outcomes
 *   appear to differ.
 */

-- ============================================
-- Q9. REGIONAL FINANCIAL & LOAN ANALYSIS
-- ============================================

-- Step 1: Calculate the average recorded balance for each account.
WITH account_balances AS (
    SELECT
        account_id,
        AVG(balance) AS average_balance
    FROM trans
    GROUP BY account_id
),

-- Step 2: Combine district information with account-level financial data.
district_accounts AS (
    SELECT
        a.account_id,
        a.district_id,
        ab.average_balance
    FROM account a
    JOIN account_balances ab
        ON a.account_id = ab.account_id
),

-- Step 3: Summarize account balances at the district level.
district_summary AS (
    SELECT
        da.district_id,
        COUNT(DISTINCT da.account_id) AS account_count,
        AVG(da.average_balance) AS average_account_balance
    FROM district_accounts da
    GROUP BY da.district_id
),

-- Step 4: Count loans and calculate loan amounts for each district.
loan_summary AS (
    SELECT
        a.district_id,
        COUNT(l.loan_id) AS loan_count,
        SUM(l.amount) AS total_loan_amount,
        COUNT(l.loan_id) FILTER (WHERE l.status = 'C') AS status_c_count,
        COUNT(l.loan_id) FILTER (WHERE l.status = 'A') AS status_a_count,
        COUNT(l.loan_id) FILTER (WHERE l.status = 'B') AS status_b_count,
        COUNT(l.loan_id) FILTER (WHERE l.status = 'D') AS status_d_count
    FROM account a
    JOIN loan l
        ON a.account_id = l.account_id
    GROUP BY a.district_id
)

-- Step 5: Combine regional economic indicators with financial
-- and loan information.
SELECT
    d.district_id,
    d.district_name,
    d.region,
    d.average_salary,
    d.unemployment_rate_1995,
    d.unemployment_rate_1996,
    COALESCE(ds.account_count, 0) AS account_count,
    ROUND(ds.average_account_balance, 2) AS average_account_balance,
    COALESCE(ls.loan_count, 0) AS loan_count,
    ROUND(COALESCE(ls.total_loan_amount, 0), 2) AS total_loan_amount,
    COALESCE(ls.status_a_count, 0) AS status_a_count,
    COALESCE(ls.status_b_count, 0) AS status_b_count,
    COALESCE(ls.status_c_count, 0) AS status_c_count,
    COALESCE(ls.status_d_count, 0) AS status_d_count
FROM district d
LEFT JOIN district_summary ds
    ON d.district_id = ds.district_id
LEFT JOIN loan_summary ls
    ON d.district_id = ls.district_id
ORDER BY d.district_id;



/*
 * Question 10: Card Tier Analysis
 * ----------------------------------------------------------------------------
 * What we're trying to analyze here:
 * - Compare transaction behavior across Junior, Classic, and Gold cards.
 * - Measure the number of transactions associated with each card tier.
 * - Calculate the total transaction amount for each card tier.
 * - Calculate the average transaction size for each card tier.
 * - Understand how transaction frequency and monetary activity differ
 *   across card tiers.
 */

-- ============================================
-- Q10. CARD TIER ANALYSIS
-- ============================================

-- Step 1: Connect each card to the account associated with its DISP relationship.
WITH card_accounts AS (
    SELECT DISTINCT
        c.card_id,
        c.card_type,
        d.account_id
    FROM card c
    JOIN disp d
        ON c.disp_id = d.disp_id
),

-- Step 2: Connect card accounts with their transaction history.
card_transactions AS (
    SELECT
        ca.card_type,
        t.trans_id,
        t.amount
    FROM card_accounts ca
    JOIN trans t
        ON ca.account_id = t.account_id
),

-- Step 3: Calculate transaction frequency and monetary metrics for each card tier.
card_summary AS (
    SELECT
        card_type,
        COUNT(DISTINCT trans_id) AS transaction_count,
        SUM(amount) AS total_transaction_amount,
        AVG(amount) AS average_transaction_size
    FROM card_transactions
    GROUP BY card_type
)

-- Step 4: Display the transaction metrics for each card tier.
SELECT
    card_type,
    transaction_count,
    ROUND(total_transaction_amount, 2) AS total_transaction_amount,
    ROUND(average_transaction_size, 2) AS average_transaction_size
FROM card_summary
ORDER BY total_transaction_amount DESC;


-- ============================================
-- FINAL BUSINESS ANALYSIS SUMMARY
-- ============================================

/*
 * Overall Business Analysis Summary
 * ----------------------------------------------------------------------------
 * The analysis covered customer demographics, account relationships,
 * transaction activity, balance trends, standing-order payments,
 * loan portfolio characteristics, debt-service burden, regional
 * financial patterns, and card-tier transaction behavior.
 *
 * Key Business Findings:
 *
 * 1. Customer Demographics & Account Base
 *    - The customer base is heavily concentrated in the 50+ age group.
 *    - The analysis also identifies the gender composition across
 *      customer age groups.
 *
 * 2. Account Ownership & Secondary Users
 *    - Most accounts are associated with a single owner.
 *    - A smaller portion of accounts also have a secondary user
 *      (DISPONENT).
 *    - Average balances can be compared between these two account structures.
 *
 * 3. Customer Transactional Activity
 *    - Account activity was measured using recency, transaction frequency,
 *      average recorded balance, and total observed inflows.
 *    - These metrics provide a basic view of account engagement and
 *      financial activity.
 *
 * 4. Balance Trend Analysis
 *    - A 30-day moving average was used to smooth short-term balance
 *      fluctuations and identify recent balance trends.
 *
 * 5. Transaction Volume & Monetary Analysis
 *    - Wire transfers represent the largest share of transaction volume
 *      among the selected transaction categories.
 *    - Cash deposits represent a smaller share of transaction count
 *      but a much larger share of total transaction amount.
 *    - This shows that transaction frequency and monetary value can tell
 *      different business stories.
 *
 * 6. Standing-Order Payment Analysis
 *    - Standing orders were analyzed by payment category using k_symbol.
 *    - SIPO represents the largest share of total standing-order payment
 *      amount in the analyzed data.
 *
 * 7. Loan Portfolio & Repayment Status
 *    - The loan portfolio was analyzed by loan count and original loan amount.
 *    - Loan status categories were compared to understand how the loan
 *      portfolio is distributed across repayment-status groups.
 *
 * 8. Debt-Service Burden
 *    - Monthly loan payments were compared with calculated average
 *      monthly account inflows.
 *    - This identifies borrowers whose monthly loan payment is high
 *      relative to their observed account inflow.
 *    - The inflow measure is based on PRIJEM transactions and should
 *      not be interpreted as confirmed salary or income.
 *
 * 9. Regional Financial & Loan Analysis
 *    - District-level salary and unemployment indicators were compared
 *      with account balances and loan activity.
 *    - The analysis helps identify regional patterns but does not establish
 *      causal relationships between economic conditions and loan outcomes.
 *
 * 10. Card Tier Analysis
 *     - Classic cards generate the highest transaction volume and total
 *       transaction amount among the analyzed card tiers.
 *     - Gold cards have the highest average transaction size.
 *     - This shows that transaction frequency and average transaction
 *       value can differ across customer card tiers.
 *
 *
 * SQL Techniques Used:
 * ----------------------------------------------------------------------------
 * - SELECT and filtering
 * - CASE expressions
 * - Aggregate functions: COUNT, SUM, AVG, MAX
 * - GROUP BY and ORDER BY
 * - JOIN and LEFT JOIN
 * - CTEs (WITH clauses)
 * - Window functions
 * - PARTITION BY
 * - ORDER BY within window functions
 * - RANGE-based moving windows
 * - ROW_NUMBER()
 * - FILTER within aggregate functions
 * - DATE conversion and DATE_TRUNC()
 * - NULLIF() and COALESCE()
 * - DISTINCT
 *
 *
 * Overall Analytical Takeaway:
 * ----------------------------------------------------------------------------
 * The SQL analysis provides a structured view of the bank's customer base,
 * account activity, payment behavior, loan portfolio, regional financial
 * conditions, and card usage patterns.
 *
 * The analysis also demonstrates an important analytical principle:
 * business conclusions should remain within the limits of the available
 * data. Observed relationships and patterns do not automatically imply
 * causation, and proxy measures such as account inflows should not be
 * treated as confirmed customer income.
 *
 *
 * SQL Analysis Complete
 * ----------------------------------------------------------------------------
 * The business analysis phase is complete.
 * The validated Berka dataset has been analyzed through ten business
 * questions using progressively applied SQL techniques.
 * The resulting analysis is ready to support the next project phase.
 */