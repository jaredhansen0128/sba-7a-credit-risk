/*
The goal here is to determine if the short-term loan effect is confounded with subprogram.
Subprogram was not included in the model, so term effect could partly reflect program mix.
Columns: subprogram_name - Subprogram names. Subprograms with less than 500 total loans are pooled under 'Other.'
         term_bin - Term length bins. The view is filtered to show only short-term loans (0-60mo) and the reference term length (61-84mo).
         loan_count - Count of loans per term_bin per subprogram.
         term_concentration - Flags rows where share_of_term exceeds 50%.
         share_of_term - Percentage displaying how much of a term_bin's loans a subprogram accounts for.
         diff_vs_ref - Difference between the 0-60mo term_bin's default rate and the reference's within each subprogram. Only reported for short-term loans.
         default_rate - Default rate per term_bin per subprogram.
         term_rate - Term_bin's default rate.
         diff_vs_term - Difference between default_rate and term_rate.
         diff_vs_portfolio - Difference between default_rate and the portfolio default rate (~7.54%).
*/

BEGIN;

DROP VIEW IF EXISTS sba.vw_shortterms_programs;

CREATE VIEW sba.vw_shortterms_programs AS

WITH cohort AS (
    SELECT m.*, r.subprogram
    FROM sba.loans_raw r
    INNER JOIN sba.vw_loans_model m
        ON r.loan_id = m.loan_id
),

cells AS (
    SELECT 
        CASE WHEN subprogram IN
                (SELECT subprogram FROM cohort
                 GROUP BY subprogram HAVING COUNT(*) < 500)
             THEN 'Other' ELSE subprogram END AS subprogram_name,
        term_bin,
        SUM(is_default) AS default_count,
        COUNT(*) AS loan_count,
        100 * AVG(is_default) AS default_rate
    FROM cohort
    GROUP BY subprogram_name, term_bin
),

rates AS (
    SELECT *,
    
        100 * SUM(default_count) OVER () / SUM(loan_count) OVER () AS portfolio_rate,

        100 * SUM(default_count) OVER (PARTITION BY term_bin) 
            / SUM(loan_count)    OVER (PARTITION BY term_bin) AS term_rate

    FROM cells
),

display AS (
    SELECT subprogram_name, term_bin, loan_count,
        ROUND(100 * loan_count / SUM(loan_count) OVER (PARTITION BY term_bin), 2) AS share_of_term,
        ROUND(default_rate, 2) AS default_rate,
        ROUND(term_rate, 2) AS term_rate,
        ROUND(default_rate - term_rate, 2) AS diff_vs_term,
        ROUND(default_rate - portfolio_rate, 2) AS diff_vs_portfolio
    FROM rates
)

SELECT subprogram_name, term_bin, loan_count,

        CASE WHEN subprogram_name = 'Other' THEN NULL
             WHEN share_of_term > 50        THEN 'High Term Concentration'
             ELSE NULL END AS term_concentration,

        share_of_term,

        default_rate - LEAD(default_rate) OVER 
            (PARTITION BY subprogram_name ORDER BY 
            SPLIT_PART(term_bin, '-', 1)::numeric)
            AS diff_vs_ref,
        
        default_rate,
        term_rate, 
        diff_vs_term,
        diff_vs_portfolio

FROM display
WHERE term_bin IN ('0-60mo', '61-84mo')
ORDER BY subprogram_name, SPLIT_PART(term_bin, '-', 1)::numeric ASC;

COMMIT;