/* PROJECT: Checkout Funnel & Friction Analysis
OBJECTIVE: Identify where users drop off in the gifting process and calculate 'Time-to-Step' 
to find technical or psychological friction.
*/

WITH UserSteps AS (
    -- Step 1: Mapping the sequence of events for each user
    SELECT 
        user_id,
        event_name,
        event_timestamp,
        -- Using LAG to pull the timestamp of the PREVIOUS action
        LAG(event_timestamp) OVER (PARTITION BY user_id ORDER BY event_timestamp) AS previous_event_timestamp,
        LAG(event_name) OVER (PARTITION BY user_id ORDER BY event_timestamp) AS previous_event_name
    FROM app_events
    WHERE event_name IN ('view_gift_shop', 'click_gift', 'checkout_page_load', 'payment_success')
),

FrictionMetrics AS (
    -- Step 2: Calculating time taken between steps (Latency/Friction)
    SELECT 
        user_id,
        previous_event_name || ' -> ' || event_name AS journey_step,
        event_timestamp,
        -- Calculate time difference in seconds
        EXTRACT(EPOCH FROM (event_timestamp - previous_event_timestamp)) AS seconds_to_next_step
    FROM UserSteps
    WHERE previous_event_name IS NOT NULL
)

-- Step 3: Final Aggregation to show Drop-off and Average Friction per step
SELECT 
    journey_step,
    COUNT(DISTINCT user_id) AS users_reached_step,
    ROUND(AVG(seconds_to_next_step), 2) AS avg_time_spent_seconds,
    -- Calculating drop-off rate compared to the previous step
    ROUND(100.0 * (1 - (COUNT(DISTINCT user_id)::float / LAG(COUNT(DISTINCT user_id)) OVER (ORDER BY MIN(event_timestamp)))), 2) AS drop_off_percentage
FROM FrictionMetrics
GROUP BY journey_step
ORDER BY MIN(event_timestamp);
