# Berka Banking & Financial Analytics

## Data Quality & Validation Report

**Project:** Berka Banking & Financial Analytics  
**Dataset:** PKDD'99 / Berka Financial Dataset  
**Purpose:** Consolidate the SQL and Python validation work, document the issues found, explain why they matter, and record how they were handled before and during business analysis.

---

## 1. Overview

The Berka dataset was loaded into a relational PostgreSQL database containing eight source tables:

- `district`
- `account`
- `client`
- `disp`
- `card`
- `loan`
- `bank_order`
- `trans`

The Python preparation notebook independently loaded and profiled the same eight source datasets.

Validation covered:

- dataset structure and row counts
- data types
- missing values
- duplicate records
- primary-key uniqueness
- foreign-key integrity
- date conversion and date ranges
- numeric ranges and suspicious values
- categorical values
- relationship consistency
- Berka-specific encoded fields
- transaction-level business conditions

The raw source data was preserved throughout the project. No source records were deleted or manually corrected during validation.

---

# 2. Validation Summary

| Validation Area | SQL | Python | Assessment |
|---|---|---|---|
| Dataset structure / row counts | PASS | PASS | Expected datasets and row counts were loaded |
| Primary-key uniqueness | PASS | PASS | No duplicate primary-key values identified |
| Primary-key NULLs | PASS | — | No NULL primary keys identified |
| Foreign-key integrity | PASS | PASS | No orphan relationships identified |
| Full-row duplicate check | — | PASS | No duplicate rows identified in the loaded Python datasets |
| Source-level `?` values | FLAG | REVIEWED | Present in selected district fields |
| Transaction missingness | FLAG | FLAG | Concentrated in optional/counterparty fields |
| Blank-space `k_symbol` | FLAG | REVIEWED | Distinct from SQL NULL and requires care |
| Zero transaction amounts | FLAG | REVIEWED | Small number; requires business context |
| Negative balances | FLAG | REVIEWED | Possible business condition, not automatically an error |
| Date ranges / formats | PASS | PASS / REVIEWED | Dates converted successfully for analysis |
| Categorical checks | PASS | REVIEWED | No confirmed invalid categorical values |
| Relationship consistency | PASS | PASS | Expected account/customer relationships were present |

---

# 3. Dataset Structure Validation

### Row Counts

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

### Assessment

All eight datasets loaded successfully with the expected row counts.

**Status: PASS**

---

# 4. Primary-Key Validation

The following primary identifiers were checked:

- `district.district_id`
- `account.account_id`
- `client.client_id`
- `disp.disp_id`
- `card.card_id`
- `loan.loan_id`
- `bank_order.order_id`
- `trans.trans_id`

SQL validation found no duplicate primary-key values and no NULL primary-key values.

Python independently checked the same identifiers and found:

- District ID duplicates: **0**
- Account ID duplicates: **0**
- Client ID duplicates: **0**
- Disposition ID duplicates: **0**
- Card ID duplicates: **0**
- Loan ID duplicates: **0**
- Order ID duplicates: **0**
- Transaction ID duplicates: **0**

### Why it matters

Primary keys identify individual records. Duplicate or missing primary keys could cause incorrect joins, failed table constraints, or double-counting.

### Assessment

**PASS — identifiers behave as expected.**

---

# 5. Foreign-Key & Relationship Validation

The following relationships were tested:

1. `account.district_id` → `district.district_id`
2. `client.district_id` → `district.district_id`
3. `disp.client_id` → `client.client_id`
4. `disp.account_id` → `account.account_id`
5. `card.disp_id` → `disp.disp_id`
6. `loan.account_id` → `account.account_id`
7. `bank_order.account_id` → `account.account_id`
8. `trans.account_id` → `account.account_id`

SQL checks returned zero orphan records.

Python checks also showed that every tested child record had a corresponding parent record.

### Why it matters

Broken relationships can produce missing customers, accounts, loans, cards, or transactions after joins and can materially distort business metrics.

### Assessment

**PASS — relational integrity is strong for the tested relationships.**

---

# 6. Missing-Value Findings

## 6.1 District Source-Level Missing Values

Two district fields contain source-level `?` placeholders:

- `unemployment_rate_1995` — **1**
- `crimes_1995` — **1**

### Why it matters

The `?` is a missing-value marker, not a numeric zero.

If converted to zero, it would create a false economic measurement and could affect regional analysis.

### Treatment

- Preserve the source record.
- Convert `?` to SQL NULL / Python missing value when numeric analysis requires it.
- Exclude the missing observation only when the specific calculation requires a complete numeric field.

### Assessment

**FLAG — low volume, but analytically important when using the affected district field.**

---

## 6.2 Transaction Missing Values

SQL and Python identified missing values in transaction fields:

| Field | Missing Records |
|---|---:|
| `operation` | 183,114 |
| `k_symbol` | 481,881 |
| `bank` | 782,812 |
| `other_account` / source `account` | 760,931 |

### Why it matters

These fields describe transaction operation, purpose/category, or counterparty information. Missingness can affect analyses that rely on those fields.

### Treatment

The values are preserved as missing.

They are **not automatically imputed**, because a missing counterparty or transaction category does not necessarily mean that the transaction itself is invalid.

### Assessment

**FLAG / REVIEWED — substantial missingness, but not automatically a data error.**

---

# 7. Blank-Space `k_symbol` Values

SQL validation identified:

**53,433 blank-space values** in transaction `k_symbol`.

### Why it matters

A blank string is different from SQL NULL.

If blanks and NULLs are treated as different categories during aggregation, the results can be fragmented or misleading.

### Treatment

The source values are preserved. Analysis should explicitly decide whether blank-space values represent an unspecified category and handle them consistently.

### Assessment

**FLAG — requires analytical normalization when `k_symbol` is used.**

---

# 8. Zero Transaction Amounts

SQL validation identified:

**14 transactions with `amount = 0.00`.**

No negative transaction amounts were identified.

### Why it matters

A zero-value transaction may represent a legitimate system/business event, but it does not contribute monetary value to amount-based metrics.

### Treatment

The records were not deleted.

They are flagged for business-context review and should only be excluded when the specific analytical question requires a positive transaction amount.

### Assessment

**FLAG — small volume; not treated as a confirmed error.**

---

# 9. Negative Transaction Balances

SQL validation identified:

**2,999 transaction records with negative recorded balances.**

By transaction type:

| Transaction Type | Negative-Balance Records |
|---|---:|
| `VYDAJ` | 2,289 |
| `PRIJEM` | 601 |
| `VYBER` | 109 |

### Why it matters

Negative balances can indicate an overdraft-like or liquidity-pressure condition. They should not automatically be treated as corrupted data.

The dataset does not tell us whether a payment would have been accepted or rejected under the bank's actual overdraft rules.

### Treatment

Negative balances were preserved and used as an observed business condition in the liquidity analysis.

In Python Q5, an account was considered to have a negative-balance observation when:

```text
balance < 0
```

The account-level negative-balance percentage was then used to classify observed liquidity pressure.

### Assessment

**BUSINESS CONDITION / FLAG — investigate as liquidity behavior, not confirmed data error.**

---

# 10. Date Validation

### Python Date Conversion

The following fields were converted to datetime:

- `account.date`
- `loan.date`
- `trans.date`
- `card.issued`

Observed ranges:

| Dataset | Start | End |
|---|---|---|
| Account | 1993-01-01 | 1997-12-29 |
| Loan | 1993-07-05 | 1998-12-08 |
| Transactions | 1993-01-01 | 1998-12-31 |
| Card | 1993-11-07 | 1998-12-29 |

SQL validation also checked the encoded date fields for invalid month/day patterns and found no confirmed invalid date patterns.

### Python Import Note

The transaction CSV initially produced a pandas `DtypeWarning` because the source transaction counterparty column contains mixed data types.

The card issue-date conversion also produced a pandas warning because the original text format was not explicitly supplied in that particular preparation step.

These warnings did not prevent successful date preparation, but they demonstrate why explicit data-type and date-format handling is important in a production workflow.

### Assessment

**PASS / REVIEWED — dates were successfully prepared for analysis, with import-format warnings documented.**

---

# 11. Categorical Validation

The SQL validation reviewed:

- account frequency
- disposition type
- card type
- loan status
- transaction type
- transaction operation
- transaction `k_symbol`
- district region

No confirmed invalid categorical values were identified.

### Treatment

Categorical values were preserved in their source form unless transformed into business-friendly labels during analysis.

For example, transaction operations were grouped into business categories for transaction-volume analysis.

### Assessment

**PASS**

---

# 12. Berka-Specific Encoded Birth Number

The `client.birth_number` field is not a normal date field.

It contains encoded birth information:

```text
YYMMDDSSSC
```

The month component also contains gender information, with female records using a month value offset by 50.

SQL validation therefore checked the encoded month and day separately rather than treating `birth_number` as a normal date.

### Why it matters

Applying ordinary date parsing directly to this field could produce incorrect birth dates or gender classifications.

### Treatment

The Python and SQL analyses handled the field separately for demographic analysis.

### Assessment

**PASS / SPECIAL-HANDLING REQUIRED**

---

# 13. Relationship Consistency

SQL checks also examined:

- whether every account had an associated customer relationship
- whether every client had an associated account relationship
- owner/disponent relationship counts
- cards linked through valid dispositions
- multiple loans per account
- transaction accounts linked to valid accounts
- standing orders linked to valid accounts
- multiple OWNER relationships

No material relationship inconsistency was identified.

### Assessment

**PASS**

---

# 14. Important Analytical Methodology Notes

These are not data-quality errors, but they are important when interpreting the final results.

## 14.1 RFM Reference Date

Python RFM uses the **latest transaction date in the dataset** as the reference date.

Therefore, recency is measured relative to the dataset's transaction horizon rather than the current real-world date.

This is appropriate for historical dataset analysis and avoids artificially making all historical customers appear inactive simply because the dataset is old.

---

## 14.2 Observed Inflows Are Not Guaranteed Income

The RFM monetary metric and debt-service analysis use `PRIJEM` transaction amounts as observed inflows.

These should be described as:

**observed account inflows**

rather than automatically calling them:

**salary, income, or guaranteed cash flow.**

---

## 14.3 Negative Balance Is Not Payment Failure

A negative recorded balance means:

```text
Recorded account balance < 0
```

It does not prove that:

- a payment failed,
- a payment was rejected,
- an account defaulted,
- or a customer was financially distressed.

---

## 14.4 District Default Rate Requires Loan-Volume Context

A district can show a high percentage because it has very few loans.

For example:

```text
1 defaulted loan / 2 total loans = 50%
```

Therefore, district default rate should be considered together with `total_loans`.

---

## 14.5 Correlation Does Not Establish Causation

The regional analysis found:

- Salary ↔ Default Rate: **0.0127**
- Unemployment ↔ Default Rate: **0.0622**
- Crime ↔ Default Rate: **-0.0124**

These values indicate very weak or near-zero linear relationships.

They should not be interpreted as proof that any macroeconomic variable causes or prevents loan default.

---

# 15. SQL vs Python Validation Reconciliation

The SQL and Python validation stages were complementary.

### SQL was used primarily for:

- relational integrity
- database-level constraints
- orphan checks
- encoded/date checks
- numeric/business-rule checks
- categorical checks
- transaction-level issue counts

### Python was used primarily for:

- dataframe structure and profiling
- duplicate-row checks
- primary-key checks
- missing-value inspection
- data-type inspection
- date conversion
- date-range review
- foreign-key membership checks
- preparation for downstream analysis

### Important Reconciliation

Python initially reports the district `?` fields as non-NULL strings because pandas reads them as text. SQL identifies their source meaning as missing values.

Therefore:

> **A source placeholder such as `?` must be interpreted semantically, not only by checking pandas `isna()`.**

---

# 16. Overall Data Quality Assessment

### Overall Status: **ANALYSIS-READY WITH DOCUMENTED CAVEATS**

The Berka dataset is structurally suitable for business analysis.

### Strong areas

- Expected row counts loaded successfully.
- Primary keys are unique.
- Primary keys are populated.
- Tested foreign-key relationships contain no orphan records.
- Main categorical domains are consistent.
- Date fields can be converted and used for time-based analysis.
- No major structural relationship issues were identified.

### Areas requiring attention

- Source-level `?` values in two district indicators.
- Substantial missingness in transaction operation/category/counterparty fields.
- Blank-space transaction categories.
- A small number of zero-value transactions.
- Negative recorded balances.
- Historical/encoded date fields requiring special handling.

### Final Decision

The raw source data should remain unchanged.

The identified conditions are documented and handled **at the analysis layer** according to the business question.

No source records were removed merely to make the dataset appear cleaner.

---

# 17. Business Impact Summary

| Finding | Business Impact | Treatment |
|---|---|---|
| District `?` values | Can affect regional indicators | Convert to missing when numeric analysis requires |
| Transaction missingness | Limits purpose/counterparty analysis | Preserve and handle contextually |
| Blank `k_symbol` | Can create separate blank category | Normalize/interpret during relevant analysis |
| Zero transaction amounts | May affect amount-based metrics slightly | Flag; no automatic deletion |
| Negative balances | Useful liquidity signal | Treat as business condition |
| Encoded birth number | Requires special demographic logic | Decode explicitly |
| Historical dates | Must use dataset reference horizon | Convert and document |
| District default rates | Small denominators can exaggerate percentages | Always show loan volume |

---

## 18. Final Conclusion

The Berka dataset does not require broad data cleaning or record deletion before analysis.

The validation work shows that the dataset is **structurally reliable but contains several analytical caveats**, particularly around optional transaction fields, source-level missing markers, negative balances, and historical/encoded fields.

The appropriate approach is therefore:

**Preserve → Validate → Flag → Handle contextually → Analyze**

rather than:

**Delete → Impute → Hide**

The SQL and Python analysis can therefore proceed with confidence, provided the documented limitations are carried into business interpretation.
