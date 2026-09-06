# SBA 7(a) Loan Charge-off Risk Analysis
## Summary
- **Data**: 348k terminal-status loans (paid in full or charged off) from FY2010-2017 analyzed via EDA and logistic regression.

- **Model**: Unpenalized logit on term length, loan size (log2), NAICS sector, revolver status, and collateral. Held-out AUC is 0.75, stable across 5 folds (0.745-0.757), and is well-calibrated.

- **Term dominates charge-off risk**: Loans with terms of 60 months or less carry about 6x higher odds of default than the reference, 61-84mo terms, and a 19.5% default rate against the 7.5% portfolio average.

- **Secured loans are associated with ~34% lower default odds than unsecured**: Since collateral is typically required of weaker borrowers, that gap likely understates its protective value.

- **Loan size impact on default rate has mixed signals**: Larger loans default less in the raw data, but the logit shows 11% higher odds per doubling of size once term and other features are held constant. Term likely drives the size effect in EDA.

- **Priors were recorded before analysis**: Retail's elevated risk was confirmed; the loan size and Construction priors were partly disconfirmed.

- **Recommendations**: Tighter controls and pricing on Retail, collateral requirements where credit quality is uncertain or borderline, and stricter acceptance criteria plus reduced concentration in short-term loans.

## About
I am a B2B Credit Analyst working for a security firm that assesses the creditworthiness of small, medium, and large businesses/organizations. I am building this project to demonstrate how my domain knowledge can be augmented with and yield actionable outputs by using Python, SQL, and statistical modeling.

## Goal
Determine which industries have higher default rates than the portfolio average and which loan sizes (split into deciles) show higher probabilities of default through EDA. Develop a logistic regression model to determine the predictive weight of each feature and compare odds ratios/findings across features.

The findings of this project can aid in policy and risk mitigation direction for small business lending. Risk mitigation strategies could include implementing collateral requirements, requiring personal guarantees, or recalibrating industry concentration limits.

## Scope
Original time window for the project was FY2000-FY2019. This has been changed to **FY2010-2017** for two reasons: 
1) The Small Business Jobs Act of 2010 permanently raised the 7(a) maximum loan size from $2M to $5M, so combining FY2000-2009 with FY2010-2019 would confound any analysis based on loan size. 
2) A significant amount of loans in FY2018 and FY2019 have not had enough time to mature, as evidenced by EXEMPT loan statuses being over 20% each year. FY2020-CurrentFY is excluded for the same reason.

The 2010-2017 period is under consistent regulation and contains both a post-crisis recovery period and an expansionary period.

## Priors
Overall, my expectation is that larger loan sizes will display higher default rates. I also believe that retail will carry high risk amongst the industries and experience high impact from loan size due to thin margins, high overhead, and fluctuating demand. Construction is in a gray area; although they are likely to pay slow due to the nature of their work, I have not witnessed many defaults or bankruptcies from companies in this sector. Construction companies also likely correlate loan size with project payout size, so I expect both this industry's impact from loan size and overall default rate to be average*.

*I worded this incorrectly; rather than 'average', I was expecting default rates for Construction to remain stable across loan sizes rather than mirroring the average industry's sensitivity to loan size.

## **Conclusion**
### Key Findings by Feature
**Gross Approval**
- In EDA, the risk of default decreased as loan size increased.

- The model indicated odds of default increased by 11% for every doubling in loan size, contradicting EDA findings.

- Term may be confounding with loan size, resulting in the mixed results between the marginal and conditional perspectives (More information available in the **Term** section).

**NAICS Sector**
- *Retail*
    - Retail's default rate of 8.81% fell above the 75th percentile of the default rate distribution between NAICS sectors. Chi-square test of independence indicated that the association between Retail's default rate and loan size is statistically significant.

    - Retail showed a 32% higher odds of default than Construction in the logit.

    - Retail showed high sensitivity to loan size, with the risk of default decreasing by over half between the lowest and highest loan size decile.

- *Construction*
    - Construction's default rate was within the IQR of the default rate distribution between NAICS sectors. We narrowly failed to reject the hypothesis that Construction is not associated with default rate.

    - Construction's default rates ranged from 6.1%-10.1% between deciles. The 10.1% default rate was a part of a decile that contained outliers amongst many sectors. With that decile removed, we failed to reject the null hypothesis that the risk of default for Construction is not significantly associated with loan size.

    - In the logit, only six other industries showed higher odds of default than Construction, suggesting that Construction displays above-average risk when all other features are held constant.

**Term**
- Term and loan size appear to be confounded. Loan size increases as term length increases, and default rate decreases as both increase. This may explain why the results from the marginal and conditional perspectives were at odds with each other; when all other features are held constant, loan size does increase default risk (by 11% for every doubling in size), but when confounders are in play, the risk lowers as size increases.

- The 0-60mo term bin exhibited the highest influence on the model. The raw default rate for this bin was 20% and the model indicated the odds of default for the 0-60mo bucket are about 6x higher than the reference, the 61-84mo bucket.

- Longer terms (120+ months) showed low risks of default (about 4% or less). These term lengths also showed 16%-71% lower odds of default than 61-84mo loans. Their sample sizes were also lower than all other bins.

**Revolver Status**
- Revolvers have a default rate 0.73ppts lower than non-revolvers in the EDA data.

- Revolvers carry a 14.8% lower odds of default than non-revolvers.

- 55% of revolvers are unsecured loans.

- Revolver status's impact on default rates may be confounded with term length and loan size since revolvers with terms of 60 months and below show a significantly higher risk of default and the majority of defaulted loans with terms of 60 months or less fall within the three smallest gross approval deciles.

- Revolving accounts beyond 120 months are likely an anomaly, since terms for revolvers are capped between 7-10 years. The anomalies exhibit a default rate of 21%.

**Collateral**
- 71% of loans have collateral reported in the EDA dataset.

- Unsecured loans showed a default rate of about 10% while secured loans had a default rate of around 7% in the EDA dataset.

- Secured loans have about 34% lower odds of default than unsecured loans.

### Model Performance
- The AUC score of 0.75 indicates the model assigns a higher predicted probability of default to a randomly chosen defaulted loan than a randomly chosen non-defaulted loan 75% of the time.

- Cross-validation showed AUCs ranged between 0.745 and 0.757 between five folds, indicating the score of 0.75 is stable.

- The calibration curve showed that the predictions aligned closely to perfect calibration.

- Variance Inflation Factor (VIF) measures how much each feature overlaps with the others. High overlap widens the uncertainty around individual coefficients in the model. No VIF exceeded 2.05 against a threshold of 5, so overlap is not distorting the estimates.

### Prior Evaluation
- *Loan Size*
    - Do Large Loans Have Higher Default Rates?: **Mixed.** Disconfirmed in the EDA data, but supported once term and all other features are held constant.

- *Retail*
    - Higher than Average Risk?: **Yes.** Confirmed decisively in both EDA and the model.

    - Sensitive to Loan Size?: **Yes, but not in the direction I expected.** The association holds, but default risk falls as loan size rises, which is the opposite of the thin-margin mechanism I predicted.

- *Construction*
    - An Average Risk Industry?: **Not quite.** Roughly average in the EDA data, but higher risk than most sectors conditionally.

    - Not Sensitive to Loan Size?: **Likely.** This is supported, but with the caveat that this depends on excluding the $100K–$150K outlier decile.

### Risk Mitigation Strategies

**Retail needs stronger risk mitigation.** 

Retail was clearly identified as a higher risk vertical with a default rate of 8.81%. A gut reaction may be to shrink portfolio concentration in this industry, but Retail has the highest loan count of all verticals (14% of all loans in the EDA data), so this recommendation would mean cutting down a large pool of revenue. A better option could be to apply collateral requirements, the benefits of which are explained below.

Interest rates could also be increased to offset risk, but only up to the SBA maximum.

If you choose to tighten industry concentration, you could try to increase business with other lower risk verticals such as Healthcare (5.12% default rate, 39% lower default odds than Retail (0.810 / 1.324), 32k sample size from EDA dataset) and Professional Services (6.56% default rate, 30% lower odds, 36k sample size).

**When in doubt, request collateral.**

Secured loans show a 35% lower odds of default than unsecured. Collateral is often required for riskier borrowers, so secured loans likely skew toward weaker credit profiles, which makes the lower default odds strong evidence that collateral works. Having secured loans would also give us priority in the event the borrower goes bankrupt. However, collateral_ind is only a flag without any details on what the collateral is or its value; further information would be needed to determine a procedure or criteria for what type or how much collateral needs to be requested.

**Decrease portfolio concentration in short-term loans and tighten qualification requirements for borrowers that need short-term loans.**

About one in five loans with short terms enter default (19.5% default rate in EDA), and the terms of the loan cannot be readily extended at origination. SBA states that terms will be *the shortest appropriate term, depending upon the borrower’s ability to repay,*[^1] which prevents us from extending terms to theoretically reduce risk. Therefore, while we can't extend terms, we can instead tighten the acceptance criteria for borrowers that require shorter terms.

Interest rates should be set close to or at the SBA maximum for these loans. Procuring personal guarantees is recommended. Closer monitoring is likely not worth the time due to the small sizes of many of these loans.

Short-term loans make up 22% of loans in the EDA data, though over 55% of short-term loans are less than or equal to $50K. The SBA guarantee covers 85% of the value of loans under $150K versus 75% for anything above that, which provides us with substantial protection in this segment; however, we still absorb 15% of the loss along with administrative costs. Given the high default rate, decreasing concentration in this segment is still recommended despite the segment's size.

[^1]: Under "Maturity Terms" in the "Terms, conditions, and eligibility for loans section" on https://www.sba.gov/sba-lenders/#types-7a-loans

### Limitations
- No borrower financials or credit information are available in the data.

- The macroeconomic conditions are not factored in the model; the vintages span years FY2010-2017, beginning from the recovery from the 2008 crisis and the following expansionary period.

- The time horizon does not include any recessionary period, so the model may understate risk in stressed conditions.

- Only terminal loans, which were either Paid In Full or Charge-Offs, were included in the data. This inherently inflates default rates and can skew towards loans which were paid off early.

- For the model, certain interactions such as Revolver x Term and Gross Approval x Term are not accounted for due to the complexity of interactions in logistic regressions.

- The model used a single pooled size slope for loan size across all NAICS sectors, so it could not test whether some industries are more sensitive to loan size than others.

## Data
SBA FOIA 7(a) loan-level CSV files from https://data.sba.gov/dataset/7-a-504-foia.
File: FY2010-FY2019, as-of date 2025-12-31. 545,751 total loans.
 - FY2018-FY2019 records are loaded but excluded from analysis in the SQL view (05_create_view.sql).
SBA updates this data quarterly, so you may see some slight variation in your data compared to mine if you download the most recent dataset.

## Setup
1. Run sql/01_create_database.sql, sql/02_create_schema.sql, and sql/03_create_table.sql against a local PostgreSQL instance in that order.
2. Run pip install -r requirements.txt in the terminal.
3. Create a .env file with DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD.
4. Run scripts/test_connection.py to verify the connection.
5. Place FY2010-FY2019 CSV in data/raw/.
6. Run scripts/load_CSVs.py.
7. Run notebooks/01_data_validation.ipynb.
8. Run sql/04_create_naics_sector_descriptions.sql followed by sql/05_create_view.sql.
9. Run notebooks/02_exploratory_data_analysis.ipynb.
10. Run sql/06_create_model_view.sql.
11. Run 03_logistic_regression_model.ipynb.