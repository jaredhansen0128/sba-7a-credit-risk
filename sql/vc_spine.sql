WITH vintage_ends AS (
    SELECT approval_fiscal_year,
           DATE_TRUNC('month', MAX(approval_date)) AS vintage_last_month
    FROM sba.vc_population_vw
    GROUP BY approval_fiscal_year
    ),

age_intervals AS (
    SELECT approval_fiscal_year,
           vintage_last_month,
           AGE(DATE_TRUNC('month', DATE '2025-12-31'), vintage_last_month) AS age_inter
    FROM vintage_ends
),

age_integers AS (
    SELECT approval_fiscal_year,
           vintage_last_month,
           (EXTRACT(YEAR FROM age_inter) * 12 + EXTRACT(MONTH FROM age_inter))::integer AS age_months
    FROM age_intervals
)

SELECT a.approval_fiscal_year,
        a.vintage_last_month,
        a.age_months, 
        s.age
FROM age_integers AS a
CROSS JOIN LATERAL generate_series(0, (age_months / 3) - 1) AS s(age)