/*
The goal here is to determine if the effect of default rates decreasing as loan size increases is due to loan size confounding with term length.
This would explain the disconnect between the findings in the marginal and conditional data.
Columns: gross_approval_decile - Loan sizes split into the same groups as in EDA. NTILE is not used since it may result in subtly different groupings.
         decile_order - An integer assigned to each gross_approval_decile to rank them from smallest to largest.
         term_bin - Term length bins.
         loan_count - Count of loans per term_bin per gross_approval_decile.
         avg_loan_size - Average loan size for each term_bin within each gross_approval_decile.
         term_concentration - Flags rows where term_share_of_decile exceeds 50%.
         term_share_of_decile - Percentage displaying what proportion of the gross_approval_decile's loan count is attributable to the term_bin.
         default_rate - Default rate per term_bin per gross_approval_decile.
         size_rate - Gross_approval_decile's overall default rate.
         diff_vs_size_rate - Difference between default_rate and size_rate.
         diff_vs_portfolio - Difference between default_rate and the portfolio default rate (~7.54%).
*/

BEGIN;

DROP VIEW IF EXISTS sba.vw_size_term;

CREATE VIEW sba.vw_size_term AS

WITH cohort AS (
    SELECT
        loan_id,
        term_bin,
        gross_approval,
        is_default,

        CASE WHEN gross_approval <=   15000 THEN 1
            WHEN gross_approval <=   25000 THEN 2
            WHEN gross_approval <=   50000 THEN 3
            WHEN gross_approval <=   65000 THEN 4
            WHEN gross_approval <=  100000 THEN 5
            WHEN gross_approval <=  150000 THEN 6
            WHEN gross_approval <=  250000 THEN 7
            WHEN gross_approval <=  401840 THEN 8
            WHEN gross_approval <=  864000 THEN 9
            WHEN gross_approval <= 5000000 THEN 10
        END AS decile_order

    FROM sba.vw_loans_model
),

cells AS (
    SELECT 
        decile_order,

        CASE decile_order
            WHEN 1 THEN '1k-15k'
            WHEN 2 THEN '15k-25k'
            WHEN 3 THEN '25k-50k'
            WHEN 4 THEN '50k-65k'
            WHEN 5 THEN '65k-100k'
            WHEN 6 THEN '100k-150k'
            WHEN 7 THEN '150k-250k'
            WHEN 8 THEN '250k-402k'
            WHEN 9 THEN '402k-864k'
            WHEN 10 THEN '864k-5M'
        END AS gross_approval_decile,

        term_bin,
        AVG(gross_approval) AS avg_loan_size,
        SUM(is_default) AS default_count,
        COUNT(*) AS loan_count,
        100 * AVG(is_default) AS default_rate
    FROM cohort
    GROUP BY decile_order, term_bin
),

rates AS (
    SELECT *,
    
        100 * SUM(default_count) OVER () / SUM(loan_count) OVER () AS portfolio_rate,

        100 * SUM(default_count) OVER (PARTITION BY gross_approval_decile)
            / SUM(loan_count)    OVER (PARTITION BY gross_approval_decile) AS size_rate

    FROM cells
),

display AS (
    SELECT gross_approval_decile, decile_order, term_bin, loan_count,
        ROUND(100 * loan_count / SUM(loan_count) OVER 
            (PARTITION BY gross_approval_decile), 2) AS term_share_of_decile,
        ROUND(default_rate, 2) AS default_rate,
        ROUND(size_rate, 2) AS size_rate,
        ROUND(default_rate - size_rate, 2) AS diff_vs_size_rate,
        ROUND(default_rate - portfolio_rate, 2) AS diff_vs_portfolio,
        ROUND(avg_loan_size, 2) AS avg_loan_size
    FROM rates
)

SELECT  gross_approval_decile,
        decile_order,
        term_bin,
        loan_count,
        avg_loan_size,
        CASE WHEN term_share_of_decile > 50 THEN 'High Term Concentration'
             ELSE NULL END AS term_concentration,
        term_share_of_decile,
        default_rate,
        size_rate,
        diff_vs_size_rate,
        diff_vs_portfolio
FROM display
ORDER BY decile_order, SPLIT_PART(term_bin, '-', 1)::numeric ASC;

COMMIT;