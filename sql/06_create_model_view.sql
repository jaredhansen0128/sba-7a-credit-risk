BEGIN;

DROP VIEW IF EXISTS sba.vw_loans_model;

CREATE VIEW sba.vw_loans_model AS

SELECT v.*, 
       CASE WHEN r.collateral_ind = 'Y' THEN 1 ELSE 0 END AS collateral_ind,
       CASE WHEN v.term_in_months BETWEEN 0 AND 60 THEN '0-60mo'
              WHEN v.term_in_months BETWEEN 61 AND 84 THEN '61-84mo'
              WHEN v.term_in_months BETWEEN 85 AND 120 THEN '85-120mo'
              WHEN v.term_in_months BETWEEN 121 AND 240 THEN '121-240mo'
              WHEN v.term_in_months BETWEEN 241 AND 324 THEN '241-324mo'
              END AS term_bin
FROM sba.vw_loans_clean AS v
JOIN sba.loans_raw AS r
USING(loan_id)
WHERE r.collateral_ind IS NOT NULL;

COMMIT;