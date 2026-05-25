BEGIN;

DROP VIEW IF EXISTS sba.vw_loans_clean;

CREATE OR REPLACE VIEW sba.vw_loans_clean AS

SELECT  loan_id,
        loan_status,
        CASE WHEN loan_status = 'CHGOFF' THEN 1 ELSE 0 END AS is_default,
        gross_approval,
        approval_fiscal_year,
        term_in_months,
        LEFT(naics_code, 2) AS two_digit_naics_sector,
        n.naics_sector_description,
        naics_code,
        naics_description,
        revolver_status,
        jobs_supported,
        approval_date
FROM sba.loans_raw AS l
JOIN sba.naics_sector_descriptions AS n
    ON n.two_digit_naics = LEFT(l.naics_code, 2)
WHERE approval_fiscal_year BETWEEN 2010 AND 2017
    AND term_in_months BETWEEN 1 AND 324
    AND jobs_supported <= 100
    AND loan_status IN ('PIF', 'CHGOFF');

COMMIT;