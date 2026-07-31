# Decisions
## Scope Decisions
FY2010-2017. Original time window for the project was FY2000-FY2019. This has been changed to FY2010-2017 for two reasons: 
1) The Small Business Jobs Act of 2010 permanently raised the 7(a) maximum loan size from $2M to $5M, so combining FY2000-2009 with FY2010-2019 would confound any analysis based on loan size. 
2) A significant amount of loans in FY2018 and FY2019 have not had enough time to mature, as evidenced by EXEMPT loan statuses being over 20% each year. FY2020-CurrentFY is excluded for the same reason.

## Cleaning Decisions
- The analysis and model will focus on loans that have terminated. As such, all loans with statuses of EXEMPT, COMMIT, and CANCLD will be removed. Only loans with statuses of PIF or CHGOFF will be used in the analysis and model.
- All loans with terms_in_months over 324 months (25 year maximum limit + 2 years extension for construction), will be removed. Terms reported as 0 will be assumed as null and removed.
- Loans with reported jobs_supported exceeding 100, the 99th percentile, will be removed.
- Rows without NAICS will be removed (2 total loans).
- Rows without jobs_supported will be removed (2 total loans).
- Geography fields are being excluded since they will not be referred to in the analysis or by the model.
- gross_approval, approval_fiscal_year, two-digit naics sector, term_in_months, and revolver_status will be used as features in the model.
- No duplicates are being removed, as some of them may be parallel loans. Only 0.7% of the included data is affected by potential duplicates. Many duplicates are in the Transportation and Warehousing sector.

## Priors Decisions
- Grocery vs specialty store prior (which would have been updated to inelastic goods vs elastic goods retailers) is removed from the project to reduce complexity.
- All remaining priors will be tested for accuracy.

## Model Decisions
- Logistic Regression is being used instead of XGBoost so that the coefficients can be evaluated.
- naics_sector will be used in the model.
- gross_approval will be a feature, but transformed to log2 due to the data being right-skewed.
- approval_fiscal_year will not be used in the model since the view contains only loans that have terminated, artificially increasing the default rate as the vintage year becomes more recent since less loans have had enough time to be paid in full.
- term_in_months will be included and binned because it clusters at specific maturities and shows a sharp level of defaults at 60 months that a continuous slope can't capture. Bins are anchored to SBA maturity caps, such as 300 representing the max for real estate and 84 representing the max for revolving accounts.
- The SQL view used for the model will be layered on the original view with the addition of collateral_ind.
- VIF of 5 or higher will be used to determine whether there is notable overlap between features.

## Dashboard
- The Power BI dashboard will no longer be included in this project to reduce complexity. 
- A second project on cloud cost analysis will be created, which may feature a Power BI dashboard.