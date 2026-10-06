BEGIN;

DROP VIEW IF EXISTS sba.vc_population_vw CASCADE;

CREATE VIEW sba.vc_population_vw AS

SELECT loan_id,
       loan_status,
       approval_fiscal_year,
       approval_date,
       charge_off_date,
       gross_charge_off_amount,
       gross_approval,
       sba_guaranteed_approval
FROM sba.loans_raw
WHERE loan_status IN ('PIF', 'CHGOFF', 'EXEMPT')
      AND NOT (loan_status = 'CHGOFF' AND charge_off_date IS NULL);

COMMIT;