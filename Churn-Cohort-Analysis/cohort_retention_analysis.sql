/* PROJECT: User Retention & Price Sensitivity Study
OBJECTIVE: Segment users into monthly cohorts to track retention and identify 
if pricing changes lead to increased churn.
*/

WITH FirstPurchase AS (
    -- Step 1: Identify the "Birth Month" of each paying user
    SELECT 
        user_id,
        MIN(DATE_TRUNC('month', transaction_timestamp)) AS cohort_month
    FROM transactions
    WHERE status = 'success'
    GROUP BY 1
),

CohortActivity AS (
    -- Step 2: Track subsequent activity for these users
    SELECT 
        fp.user_id,
        fp.cohort_month,
        DATE_TRUNC('month', t.transaction_timestamp) AS activity_month,
        -- Calculate the month index (Month 0, Month 1, etc.)
        EXTRACT(YEAR FROM t.transaction_timestamp) * 12 + EXTRACT(MONTH FROM t.transaction_timestamp) -
        (EXTRACT(YEAR FROM fp.cohort_month) * 12 + EXTRACT(MONTH FROM fp.cohort_month)) AS month_number
    FROM FirstPurchase fp
    JOIN transactions t ON fp.user_id = t.user_id
    WHERE t.status = 'success'
)

-- Step 3: Final Pivot Table for Retention Rate
SELECT 
    cohort_month,
    month_number,
    COUNT(DISTINCT user_id) AS active_users,
    -- Calculate retention % relative to Month 0
    ROUND(100.0 * COUNT(DISTINCT user_id) / 
        FIRST_VALUE(COUNT(DISTINCT user_id)) OVER (PARTITION BY cohort_month ORDER BY month_number), 2) AS retention_rate
FROM CohortActivity
GROUP BY 1, 2
ORDER BY 1, 2;
