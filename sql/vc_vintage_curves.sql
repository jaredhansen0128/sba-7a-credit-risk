/*
One row per vintage per age (quarter).
See Vintage Curves in decisions.md for further details.
*/


BEGIN;

CREATE OR REPLACE VIEW sba.vc_vintage_curves AS

WITH age_chgoffs AS (   
     SELECT loan_id,
            loan_status,
            approval_fiscal_year,
            approval_date,
            charge_off_date,
             AGE(
                 charge_off_date, 
                  approval_date
                 ) AS charge_off_inter,
            lender_share_chgoff
     FROM sba.vc_population_vw
     WHERE loan_status = 'CHGOFF'
),

q_age_chgoffs AS (
     SELECT loan_id,
       loan_status,
       approval_fiscal_year,
       approval_date,
       charge_off_date,
       ((EXTRACT(YEAR FROM charge_off_inter) * 12 + EXTRACT(MONTH FROM charge_off_inter))::integer / 3) AS charge_off_age,
       lender_share_chgoff
     FROM age_chgoffs
),

numerators AS (
     SELECT approval_fiscal_year, charge_off_age, COUNT(*) AS chgoff_loans, SUM(lender_share_chgoff) AS lender_loss
     FROM q_age_chgoffs
     GROUP BY approval_fiscal_year, charge_off_age
),

denominators AS (
     SELECT approval_fiscal_year, COUNT(*) AS disbursed_loans, SUM(lender_share_approval) AS lender_approval_total
     FROM sba.vc_population_vw
     GROUP BY approval_fiscal_year
),

inputs AS (
     SELECT s.approval_fiscal_year,
            s.age,
            COALESCE(chgoff_loans, 0) AS chgoff_count,
            COALESCE(lender_loss, 0::numeric) AS chgoff_dollars,
            disbursed_loans,
            lender_approval_total
     FROM sba.vc_spine s
     LEFT JOIN numerators n
          ON s.approval_fiscal_year = n.approval_fiscal_year
          AND s.age = n.charge_off_age
     LEFT JOIN denominators d
          ON s.approval_fiscal_year = d.approval_fiscal_year
),

cumsum AS (
     SELECT approval_fiscal_year,
            age,
            SUM(chgoff_count) OVER (
               PARTITION BY approval_fiscal_year 
               ORDER BY age
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
               ) AS cum_chgoff_count,
            SUM(chgoff_dollars) OVER (
               PARTITION BY approval_fiscal_year 
               ORDER BY age
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
               ) AS cum_chgoff_dollars,
            disbursed_loans,
            lender_approval_total
     FROM inputs
)

SELECT approval_fiscal_year,
       age,
       cum_chgoff_count,
       disbursed_loans,
       cum_chgoff_dollars,
       lender_approval_total,
       (cum_chgoff_count::numeric / disbursed_loans) AS cum_count_rate,
       cum_chgoff_dollars / lender_approval_total AS cum_dollar_rate
FROM cumsum;

COMMIT;

/* 
The query below was run as the final query to find any charge-offs not represented in the vintage curves.
A charge-off's age is the number of full quarters between approval_date and charge_off_date.
The maximum age of each vintage curve is determined by the newest loan in each fiscal year (approved Sept 30).
This allows every age in the curve to include every loan approved in the vintage.
Loans approved in the beginning of the fiscal year are up to four quarters older than the newest loan, meaning those four quarters fall beyond the end of the curves.
If any loan approved earlier in the FY was charged-off within those last four quarters, then their charge-off is not reflected in the curves.
797 charge-offs (about 2.4%) out of 33,409 are excluded from the vintage curves. They are still included in the denominator, but their charge-offs are not reflected in the numerator.

SELECT approval_fiscal_year, charge_off_age, COUNT(*)
FROM q_age_chgoffs q
WHERE NOT EXISTS (
     SELECT 1
     FROM sba.vc_spine s
     WHERE s.approval_fiscal_year = q.approval_fiscal_year
          AND s.age = q.charge_off_age
 )
GROUP BY approval_fiscal_year, charge_off_age
ORDER BY approval_fiscal_year, charge_off_age;
*/