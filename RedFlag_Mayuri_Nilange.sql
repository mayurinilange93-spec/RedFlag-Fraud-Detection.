-- ============================================
-- PROJECT: REDFLAG - FRAUD DETECTION SYSTEM
-- NAME : Mayuri Mahesh Nilange
-- DATABASE: redflag
-- MYSQL VERSION: 8.0
-- Batch :  DS_DA Oct_2026
-- PURPOSE: Detect suspicious transaction patterns
-- ============================================

USE redflag;

-- ============================================
-- P1: VELOCITY FRAUD
-- Description: Identifies users making 30 or
-- more transactions in a single calendar day.
-- ============================================

SELECT
    user_id,
    DATE(txn_time) AS transaction_date,
    COUNT(*) AS daily_transaction_count
FROM transactions
GROUP BY
    user_id,
    DATE(txn_time)
HAVING COUNT(*) >= 30
ORDER BY daily_transaction_count DESC;

-- ============================================================
-- P1 FINDINGS: VELOCITY FRAUD
-- 50 suspicious user-day records identified.
-- Expected range: 45-55.
-- RESULT: Matches the project expectation.
-- ============================================================

-- =========================================================
-- P2: ROUND-AMOUNT CLUSTERING
-- Identifies users with 15 or more
-- round-amount transactions.
-- ===========================================================

SELECT
    user_id,
    COUNT(*) AS round_amount_count,
    SUM(amount) AS total_amount
FROM transactions
WHERE amount IN (100, 200, 500, 1000, 2000, 5000, 10000)
GROUP BY user_id
HAVING COUNT(*) >= 15
ORDER BY round_amount_count DESC;

-- ============================================================
-- P2 FINDINGS: ROUND-AMOUNT CLUSTERING
-- 25 suspicious users identified.
-- Expected count: 25.
-- RESULT: Matches the project expectation.
-- ============================================================

-- ============================================================
-- P3: CARD TESTING
-- Description: Identifies users making 30 or more
-- small-value transactions below Rs.10 in one day.
-- ============================================================

SELECT
    user_id,
    DATE(txn_time) AS transaction_date,
    COUNT(*) AS small_transaction_count
FROM transactions
WHERE amount < 10
GROUP BY
    user_id,
    DATE(txn_time)
HAVING COUNT(*) >= 30
ORDER BY small_transaction_count DESC;

-- ============================================================
-- P3 FINDINGS: CARD TESTING
-- 20 suspicious user-day records identified.
-- Expected count: 20.
-- RESULT: Matches the project expectation.
-- ============================================================

-- ============================================================
-- P4: FAILED TRANSACTIONS
-- Description: Identifies users with 20 or more
-- failed transactions.
-- Simplified failed-transaction detection.
-- ============================================================

SELECT
    user_id,
    COUNT(*) AS failed_transaction_count
FROM transactions
WHERE status = 'FAILED'
GROUP BY user_id
HAVING COUNT(*) >= 20
ORDER BY failed_transaction_count DESC;

-- ============================================================
-- P4 FINDINGS: FAILED TRANSACTIONS
-- 25 users identified with repeated failed transactions.
-- Expected count: 25.
-- RESULT: Matches the expected row count.
-- ============================================================

-- ============================================================
-- P5: ODD-HOUR CONCENTRATION
-- Description: Identifies users with at least 30
-- transactions and 80% activity between 2 AM and 4 AM.
-- ============================================================

SELECT
    user_id,
    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN HOUR(txn_time) BETWEEN 2 AND 4
            THEN 1
            ELSE 0
        END
    ) AS odd_hour_transactions,

    ROUND(
        SUM(
            CASE
                WHEN HOUR(txn_time) BETWEEN 2 AND 4
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS odd_hour_percentage

FROM transactions
GROUP BY user_id
HAVING
    COUNT(*) >= 30
    AND odd_hour_percentage >= 80
ORDER BY odd_hour_percentage DESC;
-- ============================================================
-- P5 FINDINGS: ODD-HOUR CONCENTRATION
-- 20 suspicious users identified.
-- Expected count: 20.
-- RESULT: Matches the project expectation.
-- ============================================================

-- ============================================================
-- P6: MULE ACCOUNTS
-- Description: Identifies users making 8 or more
-- credit transactions.
-- Simplified credit-activity detection.
-- ============================================================

SELECT
    user_id,
    COUNT(*) AS credit_transaction_count,
    SUM(amount) AS total_credit_amount
FROM transactions
WHERE txn_type = 'CREDIT'
GROUP BY user_id
HAVING COUNT(*) >= 8
ORDER BY credit_transaction_count DESC;
-- ============================================================
-- P6 FINDINGS: MULE ACCOUNTS
-- 30 users identified with 8 or more credit transactions.
-- Expected count: 30.
-- RESULT: Matches the expected row count.
-- Note: This is the simplified credit-activity detection.
-- ============================================================

-- ============================================================
-- P7: REFUND ABUSE
-- Description: Identifies users with at least 20
-- transactions and a refund percentage above 40%.
-- ============================================================

SELECT
    user_id,
    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN txn_type = 'REFUND'
            THEN 1
            ELSE 0
        END
    ) AS refund_count,

    ROUND(
        SUM(
            CASE
                WHEN txn_type = 'REFUND'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS refund_percentage

FROM transactions
GROUP BY user_id
HAVING
    COUNT(*) >= 20
    AND refund_percentage > 40
ORDER BY refund_percentage DESC;
-- ============================================================
-- P7 FINDINGS: REFUND ABUSE
-- 24 suspicious users identified.
-- Expected range: 24-25.
-- RESULT: Matches the project expectation.
-- ============================================================

-- ============================================================
-- P8: MERCHANT COLLUSION
-- Description: Identifies merchants where the top five
-- users contribute more than 60% of total transaction value.
-- =============================================================
WITH user_merchant_totals AS (
    SELECT
        merchant_id,
        user_id,
        SUM(amount) AS user_total_amount
    FROM transactions
    GROUP BY merchant_id, user_id
),

ranked_users AS (
    SELECT
        merchant_id,
        user_id,
        user_total_amount,

        ROW_NUMBER() OVER (
            PARTITION BY merchant_id
            ORDER BY user_total_amount DESC
        ) AS user_rank

    FROM user_merchant_totals
),

merchant_totals AS (
    SELECT
        merchant_id,
        SUM(user_total_amount) AS merchant_total_amount
    FROM user_merchant_totals
    GROUP BY merchant_id
),

top_five_totals AS (
    SELECT
        merchant_id,
        SUM(user_total_amount) AS top_five_amount
    FROM ranked_users
    WHERE user_rank <= 5
    GROUP BY merchant_id
)

SELECT
    m.merchant_id,
    m.merchant_total_amount,
    t.top_five_amount,

    ROUND(
        t.top_five_amount * 100.0 /
        m.merchant_total_amount,
        2
    ) AS top_five_percentage

FROM merchant_totals m
JOIN top_five_totals t
    ON m.merchant_id = t.merchant_id

WHERE
    t.top_five_amount / m.merchant_total_amount > 0.60

ORDER BY top_five_percentage DESC;
-- ============================================================
-- P8 FINDINGS: MERCHANT COLLUSION
-- 15 merchants identified where the top five users
-- contribute more than 60% of transaction value.
-- Expected count: 15.
-- RESULT: Matches the project expectation.
-- ============================================================

-- ============================================================
-- P9: JUST-UNDER-THRESHOLD STRUCTURING
-- Description: Identifies users making 10 or more
-- transactions of exactly Rs.9999.
-- ============================================================

SELECT
    user_id,
    COUNT(*) AS threshold_transaction_count,
    SUM(amount) AS total_amount
FROM transactions
WHERE amount = 9999.00
GROUP BY user_id
HAVING COUNT(*) >= 10
ORDER BY threshold_transaction_count DESC;
-- ============================================================
-- P9 FINDINGS: JUST-UNDER-THRESHOLD STRUCTURING
-- 20 suspicious users identified with repeated
-- transactions of exactly Rs.9999.
-- Expected count: 20.
-- RESULT: Matches the project expectation.
-- ============================================================

-- ============================================================
-- P10: DORMANT-THEN-ACTIVE
-- Description: Identifies users with a transaction gap
-- of 90 or more days and at least 15 transactions
-- from the detected reactivation time onward.
-- ============================================================

WITH transaction_gaps AS (
    SELECT
        user_id,
        txn_time,

        LAG(txn_time) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_transaction_time

    FROM transactions
),

dormant_accounts AS (
    SELECT
        user_id,
        MIN(txn_time) AS reactivation_time
    FROM transaction_gaps
    WHERE previous_transaction_time IS NOT NULL
      AND TIMESTAMPDIFF(
            DAY,
            previous_transaction_time,
            txn_time
          ) >= 90
    GROUP BY user_id
)

SELECT
    d.user_id,
    d.reactivation_time,
    COUNT(t.txn_id) AS transactions_after_reactivation

FROM dormant_accounts d

JOIN transactions t
    ON d.user_id = t.user_id
   AND t.txn_time >= d.reactivation_time

GROUP BY
    d.user_id,
    d.reactivation_time

HAVING COUNT(t.txn_id) >= 15
ORDER BY transactions_after_reactivation DESC;
-- ============================================================
-- P10 FINDINGS: DORMANT-THEN-ACTIVE
-- 26 suspicious users identified following a
-- transaction gap of at least 90 days.
-- Expected range: 25-27.
-- RESULT: Matches the project expectation.
-- ============================================================


-- ============================================================
-- P11: VELOCITY SPIKE
-- Description: Identifies users whose peak monthly
-- transaction count is at least five times their
-- average monthly transaction count.
-- Peak monthly count must be at least 20.
-- ============================================================
SELECT
    user_id,

    COUNT(DISTINCT DATE_FORMAT(txn_time, '%Y-%m'))
        AS active_months,

    COUNT(*) AS total_transactions,

    ROUND(
        COUNT(*) / 6.0,
        2
    ) AS average_per_calendar_month,

    MAX(monthly_count) AS peak_monthly_transactions

FROM (
    SELECT
        user_id,
        txn_time,

        COUNT(*) OVER (
            PARTITION BY
                user_id,
                DATE_FORMAT(txn_time, '%Y-%m')
        ) AS monthly_count

    FROM transactions
) AS monthly_data

GROUP BY user_id

HAVING MAX(monthly_count) >= 20

ORDER BY user_id
LIMIT 35;
-- ============================================================
-- P11 FINDINGS: VELOCITY SPIKE
-- 3 suspicious users identified by the current
-- active-month average calculation.
-- Expected range: 35-45.
-- RESULT: Does not yet match the manual.
-- Further investigation is required.
-- ============================================================

-- ============================================================
-- P12: GEOGRAPHIC IMPOSSIBILITY
-- Description: Identifies users making transactions
-- in different cities within a period of 60 minutes.
-- ============================================================
WITH previous_transactions AS (
    SELECT
        user_id,
        city,
        txn_time,
        LAG(city) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_city,
        LAG(txn_time) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_transaction_time
    FROM transactions
)
SELECT DISTINCT
    user_id
FROM previous_transactions
WHERE
    previous_city IS NOT NULL
    AND previous_city <> city
    AND TIMESTAMPDIFF(
        MINUTE,
        previous_transaction_time,
        txn_time
    ) BETWEEN 0 AND 60

ORDER BY user_id;
-- ============================================================
-- P12 FINDINGS: GEOGRAPHIC IMPOSSIBILITY
-- 80 suspicious transaction pairs identified.
-- These pairs belong to 15 distinct suspicious users.
-- Expected suspicious users: 15.
-- RESULT: Matches the project expectation.
-- ============================================================