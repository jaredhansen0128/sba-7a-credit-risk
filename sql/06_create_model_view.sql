BEGIN;

DROP VIEW IF EXISTS sba.vw_loans_model;

CREATE VIEW sba.vw_loans_model AS

SELECT v.*, 
       CASE WHEN r.collateral_ind = 'Y' THEN 1 ELSE 0 END AS collateral_ind
FROM sba.vw_loans_clean AS v
JOIN sba.loans_raw AS r
USING(loan_id)
WHERE r.collateral_ind IS NOT NULL;

COMMIT;