BEGIN;

CREATE OR REPLACE VIEW sba.vc_population_vw AS

WITH loans_with_share AS (
      SELECT loan_id,
             loan_status,
             approval_fiscal_year,
             approval_date,
             charge_off_date,
             gross_charge_off_amount,
             gross_approval,
             sba_guaranteed_approval,
             1 - (sba_guaranteed_approval / gross_approval) AS lender_share
      FROM sba.loans_raw
      WHERE loan_status IN ('PIF', 'CHGOFF', 'EXEMPT')
            AND NOT (loan_status = 'CHGOFF' AND charge_off_date IS NULL)
)

SELECT *,
       CASE WHEN loan_status = 'CHGOFF'
            THEN gross_charge_off_amount * lender_share
            ELSE NULL 
            END AS lender_share_chgoff,
       gross_approval * lender_share AS lender_share_approval
FROM loans_with_share;

COMMIT;