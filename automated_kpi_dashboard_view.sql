/* PROJECT: Automated Business Reporting Pipeline
OBJECTIVE: Create a single source of truth for Marketing and Product teams
to eliminate manual ad-hoc requests and human error.
*/

CREATE OR REPLACE VIEW daily_business_kpis AS
WITH DailyEngagement AS (
    -- Aggregating session data (DAU)
    SELECT 
        event_date,
        platform,
        COUNT(DISTINCT user_id) AS dau
    FROM user_logs
    GROUP BY 1, 2
),

DailyRevenue AS (
    -- Aggregating revenue with strict status filters for Data Integrity
    SELECT 
        transaction_date,
        platform,
        SUM(amount) AS gross_revenue,
        COUNT(transaction_id) AS total_orders,
        -- Ensuring only successful payments are counted
        SUM(CASE WHEN payment_status = 'completed' THEN amount ELSE 0 END) AS net_revenue
    FROM sales_records
    WHERE is_test_account = FALSE -- Filtering out internal test data
    GROUP BY 1, 2
)

-- Final Join to provide a clean reporting table for Power BI/Tableau
SELECT 
    e.event_date,
    e.platform,
    e.dau,
    r.net_revenue,
    -- ARPU: Average Revenue Per User
    ROUND(COALESCE(r.net_revenue, 0) / e.dau, 2) AS arpu,
    -- Conversion Rate
    ROUND(100.0 * r.total_orders / e.dau, 2) AS conversion_pct
FROM DailyEngagement e
LEFT JOIN DailyRevenue r ON e.event_date = r.transaction_date AND e.platform = r.platform;
