WITH users_cleaned AS (
    SELECT 
        user_id,
        promo_signup_flag,
        to_date(
            REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '-', '.'),
            CASE 
                WHEN LENGTH(REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '-', '.')) = 10 
                    THEN 'DD.MM.YYYY'
                ELSE 'DD.MM.YY'
            END
        ) AS signup_date
    FROM project.cohort_users_raw
),


events_cleaned AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        to_date(
            REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '-', '.'),
            CASE 
                WHEN LENGTH(REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '-', '.')) = 10 
                    THEN 'DD.MM.YYYY'
                ELSE 'DD.MM.YY'
            END
        ) AS event_date
    FROM project.cohort_events_raw
)


SELECT 
    u.promo_signup_flag,

    TO_CHAR(u.signup_date, 'YYYY-MM') AS cohort_month,

    (EXTRACT(YEAR FROM e.event_date) - EXTRACT(YEAR FROM u.signup_date)) * 12 +
    (EXTRACT(MONTH FROM e.event_date) - EXTRACT(MONTH FROM u.signup_date)) AS month_offset,

    COUNT(DISTINCT u.user_id) AS users_total
FROM users_cleaned u
JOIN events_cleaned e ON u.user_id = e.user_id
WHERE 

    u.signup_date IS NOT NULL 
    AND e.event_date IS NOT NULL

    AND e.event_type IS NOT NULL 
    AND e.event_type != 'test_event'

    AND u.signup_date BETWEEN '2025-01-01' AND '2025-06-30'
    AND e.event_date BETWEEN '2025-01-01' AND '2025-06-30'
GROUP BY 
    u.promo_signup_flag,
    TO_CHAR(u.signup_date, 'YYYY-MM'),
    month_offset

ORDER BY 
    u.promo_signup_flag,
    cohort_month,
    month_offset;