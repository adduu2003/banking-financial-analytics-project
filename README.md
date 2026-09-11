# Berka Banking & Financial Analytics | PKDD'99 Dataset

**Author:** ADEEB MUZAFFAR  
**Date:** 10-Sep-2026  
**Version:** 1.0  
**Status:** SQL & Python Complete | Excel In Progress

---

## 📊 Project Overview

This project uses the **PKDD'99 / Berka Financial Dataset** to build a relational PostgreSQL database and analyze banking activity from both a data-quality and business perspective.

The project follows an end-to-end analytics workflow:

1. **SQL** — database setup, profiling, validation, and business analysis.
2. **Python** — data preparation, validation, customer/account/loan/regional analysis, and visualizations.
3. **Excel** — final business presentation and dashboard development.

The analytical focus moves through four business areas:

**Customer Value → Account Liquidity → Credit Risk → Geographic Macro-Risk**

The workflow follows a simple structure:

**Prepare the data → Validate it → Analyze it → Visualize it → Present the business insights**

---

## 📁 Project Structure

```text
berka-banking-financial-analytics/
│
├── 01_berka_setup_and_profiling.sql
├── 02_berka_data_validation.sql
├── 03_berka_sql_analysis.sql
├── DataQuality.md
│
├── 01_data_preparation_and_profiling.ipynb
├── 02_berka_python_analysis.ipynb
│
├── excel/
│   └── berka_banking_dashboard.xlsx
│
└── README.md
```

### File Purpose

| File | Purpose |
|---|---|
| `01_berka_setup_and_profiling.sql` | Creates the 8-table PostgreSQL schema, relationships, constraints, indexes, loads/profiles the data, and verifies row counts |
| `02_berka_data_validation.sql` | Performs data-quality, integrity, date, numeric, categorical, and relationship checks |
| `03_berka_sql_analysis.sql` | Contains 10 SQL business-analysis questions covering customers, accounts, transactions, standing orders, loans, regions, and cards |
| `DataQuality.md` | Consolidated SQL + Python data-quality assessment, flags, impact, treatment, and analytical limitations |
| `01_data_preparation_and_profiling.ipynb` | Loads, prepares, profiles, validates, and checks the eight Berka datasets in Python |
| `02_berka_python_analysis.ipynb` | Performs 12 business-analysis questions across four analytical modules with visualizations and business insights |
| `excel/berka_banking_dashboard.xlsx` | Final Excel dashboard and presentation layer — pending |
| `README.md` | Project overview, analytical scope, workflow, findings, tools, and status |

---

## 📈 Dataset Overview

### Source

**PKDD'99 / Berka Financial Dataset**

The Berka dataset is a relational banking dataset containing anonymized customer, account, transaction, loan, card, standing-order, and district-level information.

### Source Tables

The PostgreSQL database contains **8 normalized tables**:

1. `district`
2. `account`
3. `client`
4. `disp`
5. `card`
6. `loan`
7. `bank_order`
8. `trans`

### Dataset Size

| Table | Rows |
|---|---:|
| `district` | 77 |
| `account` | 4,500 |
| `client` | 5,369 |
| `disp` | 5,369 |
| `card` | 892 |
| `loan` | 682 |
| `bank_order` | 6,471 |
| `trans` | 1,056,320 |

The transaction table is the largest analytical table, containing more than **1.05 million transaction records**.

---

## 🧱 Database Design

The database is normalized around the main banking entities and their relationships.

Key relationships include:

- `district` → `account`
- `district` → `client`
- `client` → `disp`
- `account` → `disp`
- `disp` → `card`
- `account` → `loan`
- `account` → `bank_order`
- `account` → `trans`

Primary keys and foreign-key constraints were defined in PostgreSQL, with indexes added to frequently joined and filtered columns, particularly account, district, customer relationship, loan, standing-order, and transaction fields.

The raw source naming was retained in Python, while the SQL schema uses clearer analytical names such as `create_date`, `grant_date`, `trans_date`, `trans_type`, `disp_type`, `card_type`, and `other_account`.

---

## ❓ SQL Business Questions

The SQL phase contains **10 business questions**.

### Customer & Account Analysis

**Q1. Customer Demographics & Acquisition**  
Analyze customer age cohorts and gender using the encoded `birth_number` and customer-account relationships.

**Q2. Account Ownership & Secondary Users**  
Compare single-owner accounts with accounts that have secondary users and examine their latest recorded balance profiles.

**Q3. Customer Transactional Activity**  
Measure account activity using latest transaction date, transaction frequency, average recorded balance, and observed inflows.

### Transaction & Payment Analysis

**Q4. 30-Day Moving Average Balance**  
Use a 30-day moving average to smooth short-term balance fluctuations and identify recent balance patterns.

**Q5. Transaction Volume & Monetary Analysis**  
Compare major transaction categories by transaction volume and monetary value.

**Q6. Standing Order Payment Analysis**  
Analyze standing-order payment categories, counts, total payment amounts, and their share of standing-order activity.

### Credit & Regional Analysis

**Q7. Loan Portfolio & Repayment Status**  
Measure loan counts, total exposure, and portfolio shares across repayment statuses.

**Q8. Debt-Service Burden**  
Compare scheduled monthly loan payments with observed monthly account inflows to assess repayment pressure.

**Q9. Regional Financial & Loan Analysis**  
Compare district-level salary and unemployment indicators with account balances and loan activity.

**Q10. Card Tier Analysis**  
Compare transaction volume, total transaction value, and average transaction size across card tiers.

---

## 🐍 Python Analysis

The Python phase is organized into two notebooks.

### 01 — Data Preparation & Profiling

The first notebook prepares the data before business analysis.

It covers:

- Loading all eight datasets
- Dataset shape and structure
- Data previews
- Column and data-type checks
- Descriptive statistics
- Missing-value checks
- Duplicate checks
- Primary-key duplicate checks
- Date conversion and range checks
- Foreign-key validation

The Python preparation phase confirmed the expected row counts and found no duplicate primary-key values or orphaned foreign-key relationships.

### 02 — Business Analysis

The second notebook contains **four analytical modules and 12 business questions**.

---

### MODULE 1 — Customer Value & Cards

**Q1 — RFM Analysis**  
Calculate customer-level Recency, Frequency, and Monetary metrics using observed transaction behavior.

**Q2 — RFM Scoring & Segmentation**  
Convert RFM measures into scores and classify customers into Low, Medium, and High observed-value segments.

**Q3 — RFM Segment vs Card Tier**  
Compare customer-value segments with card adoption and card tiers.

**Key result:**  
The RFM segmentation produced three balanced groups:

- **Low:** 1,253
- **Medium:** 1,252
- **High:** 1,253

Card transaction behavior also differed across tiers. Classic cards generated the highest observed transaction volume and total transaction value, while Gold cards recorded the highest average transaction size.

---

### MODULE 2 — Balance Behavior & Liquidity

**Q4 — Standing Orders vs Balance Behavior**  
Compare standing-order activity groups with observed average account balances.

**Q5 — Drawdown & Liquidity Stability**  
Measure how frequently accounts recorded negative transaction balances.

**Q6 — Moving Balance Trajectory**  
Use a 30-day moving average to distinguish short-term balance fluctuations from broader account balance patterns.

**Key result:**  
Standing-order activity groups showed increasing typical observed average balances from Low to Medium to High activity.

The validation also identified **2,999 transactions with negative recorded balances**:

- **VYDAJ:** 2,289
- **PRIJEM:** 601
- **VYBER:** 109

These negative balances were treated as potential liquidity/overdraft-like business conditions rather than confirmed data errors.

The moving-average analysis provides a smoother account-level view and helps distinguish short-term balance movements from broader patterns.

---

### MODULE 3 — Credit Risk Drivers

**Q7 — Loan Portfolio & Repayment Status**  
Analyze loan distribution and exposure by repayment status.

**Q8 — Debt-Service Burden & Repayment Pressure**  
Compare scheduled loan payments with observed average monthly inflows.

**Q9 — Loan Risk by Term & Amount**  
Examine the relationship between loan amount, duration, and repayment status.

**Key result:**  
The portfolio contains **682 loans** with total exposure of approximately **103.26 million**.

Status C represents:

- **403 loans**
- **59.09% of loan count**
- **66.90% of total loan exposure**

Status B represents **31 loans (4.55%)** and approximately **4.22% of total loan exposure**.

Debt-service burden analysis showed that most observed loans have relatively lower scheduled-payment burden compared with observed average monthly inflows, while a smaller group has substantially higher repayment pressure.

Loan amount and duration also show a clear positive portfolio pattern: larger loans generally tend to have longer repayment durations.

---

### MODULE 4 — Geographic Macro-Risk

**Q10 — Regional Loan Risk & Default Rate**  
Build a district-level dataset combining observed loan default rates with regional economic indicators.

**Q11 — Macro-Risk Correlation Analysis**  
Measure correlations between average salary, unemployment, crime, and observed default rate.

**Q12 — Unemployment vs Default Relationship**  
Use district-level observations and a regression scatter plot to visually examine unemployment versus observed default rate.

**Key result:**  
Observed default rates vary across districts, but the district-level macroeconomic variables did not show meaningful linear relationships with default rate.

Correlation with observed default rate:

| Indicator | Correlation |
|---|---:|
| Average Salary | **0.0127** |
| Unemployment Rate | **0.0622** |
| Crime Rate | **-0.0124** |

The unemployment-versus-default scatter plot also showed widely dispersed district observations rather than a clear upward linear pattern.

A high district default percentage should also be interpreted with its loan population. For example, Sokolov recorded a **50% observed default rate**, but this represented **1 defaulted loan out of only 2 loans**.

---

## 🔍 Data Quality Summary

Data quality was assessed independently through both SQL and Python before and during analysis.

### Validation Summary

| Validation Area | Result |
|---|---|
| Dataset structure and row counts | **PASS** |
| Primary-key uniqueness | **PASS** |
| Primary-key NULL checks | **PASS** |
| Foreign-key integrity | **PASS** |
| Python duplicate-row checks | **PASS** |
| Date conversion and range review | **PASS / REVIEWED** |
| Source-level missing values | **FLAG / REVIEWED** |
| Transaction optional-field missingness | **FLAG / REVIEWED** |
| Zero-value transactions | **FLAG** |
| Negative transaction balances | **BUSINESS CONDITION / FLAG** |
| Categorical values | **PASS** |
| Relationship consistency | **PASS** |

### Main Findings

- Two district-level source fields contain a single `?` value each: unemployment for 1995 and crimes for 1995.
- Transaction-level optional/counterparty fields contain substantial missing values:
  - `operation`: **183,114**
  - `k_symbol`: **481,881**
  - `bank`: **782,812**
  - `other_account`: **760,931**
- **53,433** blank-space values were identified in transaction `k_symbol`.
- **14** transactions have a zero transaction amount.
- **2,999** transaction records have negative recorded balances.
- No duplicate primary-key values were found.
- No orphan foreign-key relationships were found.
- No major categorical-domain or date-format problems were identified.

The raw data was preserved. No source records were deleted or manually corrected as part of validation.

For the complete assessment, impact, treatment decisions, and SQL/Python reconciliation notes, see:

`DataQuality.md`

---

## 💼 Business Insights

### Customer Value

The RFM analysis creates a practical customer-value framework that differentiates customers using observed transaction behavior. The balanced Low, Medium, and High segments can support differentiated customer engagement and retention strategies.

Card-tier analysis adds another layer by showing how transaction behavior differs across card products.

### Account Liquidity

Standing-order activity and balance behavior provide complementary views of account liquidity. Higher standing-order activity groups showed higher typical observed balances, while negative-balance analysis identified a smaller group of accounts experiencing recorded negative balances.

The 30-day moving average adds a time-based view of account behavior and helps identify broader balance patterns rather than relying on individual transaction movements.

### Credit Risk

Credit exposure is concentrated in status C, while a smaller group of loans falls into other repayment-status categories. Debt-service burden highlights loans where scheduled monthly payments are high relative to observed account inflows.

Loan amount and duration also move together in the observed portfolio, with larger loans generally having longer repayment terms.

### Geographic Risk

Regional macroeconomic indicators provide useful context, but they were not strong standalone explanations of observed default-rate variation in this dataset. The analysis therefore supports combining geographic information with customer, account, transaction, and loan-level factors rather than relying on regional indicators alone.

---

## 📊 Visualizations

The Python project includes business-focused visualizations across the four modules:

### Module 1
- RFM Segment vs Card Tier — stacked percentage bar chart

### Module 2
- Standing-Order Activity vs Account Balance — box plot
- Liquidity Pressure Distribution — bar chart
- 30-Day Moving Balance Trajectory — line chart

### Module 3
- Loan Exposure by Repayment Status — bar chart
- Debt-Service Burden Distribution — histogram
- Loan Amount vs Loan Duration — scatter plot

### Module 4
- Regional Default Rate — horizontal bar chart
- Macro-Risk Correlation — correlation heatmap
- Unemployment vs Default Rate — regression scatter plot

The visualizations are designed to support business interpretation rather than simply display statistical output.

---

## 🧮 Important Metric Definitions

### RFM

- **Recency:** Days since the customer's most recent observed transaction, using the latest transaction date in the dataset as the reference date.
- **Frequency:** Number of observed transactions associated with the customer.
- **Monetary:** Total observed `PRIJEM` inflows associated with the customer.

### Negative Balance

A transaction is considered a negative-balance observation when the recorded `balance < 0` after the transaction.

This does **not** mean that a payment failed or that the customer defaulted.

### Debt-Service Burden

```text
Debt-Service Burden (%) =
Scheduled Monthly Loan Payment
÷ Observed Average Monthly Inflow
× 100
```

The inflow measure is based on observed `PRIJEM` transactions and should not automatically be interpreted as salary or guaranteed income.

### Observed Default Rate

```text
Default Rate (%) =
Defaulted Loans (Status B)
÷ Total Loans
× 100
```

The district-level default rate is an observed portfolio measure and should be interpreted together with the number of loans in the district.

### Correlation

Correlation measures the direction and strength of a linear association between variables. It does not establish causation.

---

## 🛠️ Technical Stack

| Component | Technology |
|---|---|
| Database | PostgreSQL |
| SQL | SQL |
| Python | Python |
| Data Analysis | pandas, NumPy |
| Visualization | Matplotlib |
| Documentation | Markdown |
| Final Presentation | Excel — In Progress |
| Development Environment | Jupyter Notebook / pgAdmin |

---

## 📋 How I Handled the Data

The project follows a traceable data-handling process:

- Preserve the raw source data
- Build a relational database with keys and relationships
- Profile the datasets before analysis
- Validate primary and foreign-key integrity
- Review missing and source-level placeholder values
- Check numeric ranges and categorical domains
- Review date fields before time-based analysis
- Flag unusual transaction conditions rather than automatically deleting them
- Use business-question-specific filters and aggregations
- Document important limitations and assumptions

The purpose of validation was to understand the data and its limitations, not to make the source dataset appear artificially clean.

---

## 🚀 Project Workflow

### Phase 1 — SQL

**Status: ✅ Complete**

- PostgreSQL schema creation
- Table relationships and constraints
- Strategic indexing
- Row-count verification
- Data profiling
- Data-quality validation
- 10 SQL business questions
- Validation findings documented

### Phase 2 — Python

**Status: ✅ Complete**

- Data loading
- Data preparation
- Date conversion
- Missing-value review
- Duplicate and key validation
- Foreign-key validation
- 4 analytical modules
- 12 business questions
- Business-focused visualizations
- Module-level business insights

### Phase 3 — Excel

**Status: ⏳ In Progress**

The final Excel layer will bring together the most useful metrics and insights from the SQL and Python analysis into a business-friendly presentation.

---

## 📊 Final Insights & Recommendations

The current analytical phase has established the core findings across customer value, liquidity, credit risk, and geographic risk.

The final recommendations and management-facing dashboard will be finalized after the Excel phase so that the presentation layer remains consistent with the completed analysis.

---

## 📄 Detailed Documentation

For the complete SQL and Python data-quality assessment, flagged conditions, impact, treatment decisions, and methodology notes:

**`DataQuality.md`**

---

## 📌 Project Status

| Phase | File / Area | Status |
|---|---|---|
| Database Setup & Profiling | `01_berka_setup_and_profiling.sql` | ✅ Complete |
| Data Validation | `02_berka_data_validation.sql` | ✅ Complete |
| SQL Business Analysis | `03_berka_sql_analysis.sql` | ✅ Complete |
| Consolidated Data Quality Report | `DataQuality.md` | ✅ Complete |
| Python Data Preparation & Profiling | `01_data_preparation_and_profiling.ipynb` | ✅ Complete |
| Python Business Analysis | `02_berka_python_analysis.ipynb` | ✅ Complete |
| Excel Dashboard | `excel/` | ⏳ In Progress |
| Final Management Recommendations | README | ⏳ Pending Excel |

**Current Status: SQL & Python Complete | Excel In Progress**

---

## 📚 Dataset

This project uses the **PKDD'99 / Berka Financial Dataset**.

The analysis is based on the anonymized relational banking dataset and its eight source tables.

---

## 👤 Author

**ADEEB MUZAFFAR**

Project: **Berka Banking & Financial Analytics**

Project date: **10-Sep-2026**

- **GitHub:** https://github.com/adduu2003
- **LeetCode:** https://leetcode.com/u/adduu_2003/

---

## License

This project uses the PKDD'99 / Berka Financial Dataset. Refer to the original dataset source and accompanying documentation for applicable dataset terms and attribution requirements.
