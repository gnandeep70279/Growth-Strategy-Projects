# 🛒 Checkout Funnel & Friction Analysis

## Business Problem
The gifting funnel was experiencing a significant drop-off at the final stage. I needed to identify if this was due to technical latency or psychological friction (price shock).

## Technical Approach
* **SQL Window Functions:** Used `LAG()` to calculate the time elapsed between steps for each unique user.
* **Metric:** "Time-to-Step" and "Step-by-Step Conversion Rate."

## Insights & Impact
* **Discovery:** Identified a 70% drop-off at the final payment screen with a high "Time-to-Step" average.
* **Recommendation:** Proposed UI transparency for service fees to reduce "transactional anxiety."
* **Projected Result:** 12% uplift in total conversion.
