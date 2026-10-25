-- sql/01_advanced_features.sql
-- This pipeline generates advanced features for the Credit Risk Model.
-- Engine: DuckDB or PostgreSQL

WITH RECURSIVE 
-- 1. Base customer data (mocking the Kaggle dataset structure)
raw_customers AS (
    SELECT 
        customer_id,
        CAST(application_date AS DATE) as application_date,
        loan_amount,
        target_default
    FROM raw_loan_data
),

-- 2. Recursive CTE: Generate a monthly calendar to align transactions
calendar AS (
    SELECT MIN(application_date) as dt FROM raw_customers
    UNION ALL
    SELECT dt + INTERVAL 1 MONTH
    FROM calendar
    WHERE dt < (SELECT MAX(application_date) FROM raw_customers)
),

-- 3. Aggregate monthly payment behavior
monthly_activity AS (
    SELECT 
        c.customer_id,
        cal.dt as activity_month,
        COALESCE(SUM(p.payment_amount), 0) as total_paid,
        COALESCE(SUM(p.amount_due), 0) as total_due,
        COUNT(CASE WHEN p.payment_amount < p.amount_due THEN 1 END) as late_payments
    FROM raw_customers c
    JOIN calendar cal ON c.application_date >= cal.dt
    LEFT JOIN raw_payments p ON c.customer_id = p.customer_id 
        AND p.payment_date >= cal.dt 
        AND p.payment_date < cal.dt + INTERVAL 1 MONTH
    GROUP BY 1, 2
),

-- 4. Advanced Window Functions: Rolling behavior metrics
rolling_features AS (
    SELECT 
        customer_id,
        activity_month,
        total_paid,
        total_due,
        late_payments,
        
        -- Rolling 6-month average payment ratio
        AVG(total_paid / NULLIF(total_due, 0)) OVER (
            PARTITION BY customer_id 
            ORDER BY activity_month 
            ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
        ) as rolling_6m_payment_ratio,

        -- Rolling 3-month late payment count
        SUM(late_payments) OVER (
            PARTITION BY customer_id 
            ORDER BY activity_month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) as rolling_3m_late_payments,

        -- NTILE: Segment customers into risk deciles based on rolling late payments
        NTILE(10) OVER (
            PARTITION BY activity_month 
            ORDER BY late_payments DESC
        ) as risk_decile

    FROM monthly_activity
)

-- 5. Final feature table for the ML model
SELECT 
    customer_id,
    MAX(activity_month) as last_active_month,
    MAX(rolling_6m_payment_ratio) as max_6m_payment_ratio,
    SUM(rolling_3m_late_payments) as total_late_payments,
    MAX(risk_decile) as worst_risk_decile
FROM rolling_features
GROUP BY 1;
