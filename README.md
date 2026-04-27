# sba-7a-credit-risk
## Goal
Determine which industries, loan sizes, and vintages have higher default rates than the portfolio average. Examine how default rates interact across these features with an emphasis on identifying which industries are most sensitive to loan size. Develop a logistic regression model to determine the predictive weight of each feature.

Findings can aid in policy and risk mitigation direction for small business lending. Risk mitigation strategies could include implementing collateral requirements, requiring personal guarantees, or recalibrating industry concentration limits.

## Priors
In general, larger loan sizes and the 2008-2010 vintage will likely display higher default rates. I expect that retail will carry high risk amongst the industries and experience high impact from loan size due to thin margins, high overhead, and fluctuating demand. Grocery stores will display more resilience than speciality stores. Construction is in a gray area; although they are likely to pay slow due to the nature of their work, I have not witnessed many defaults or bankruptcies from companies in this sector. Construction companies also likely correlate loan size with project payout size, so I expect both this industry's impact from loan size and overall default rate to be average.

## Setup
Run sql/01_create_database, sql/02_create_schema, and sql/03_create_table against a local PostgreSQL instance.