# sba-7a-credit-risk
## Goal
Determine which industries, loan sizes, and vintages have higher default rates than the portfolio average. Examine how default rates interact across these features with an emphasis on identifying which industries are most sensitive to loan size. Develop a logistic regression model to determine the predictive weight of each feature.

Findings can aid in policy and risk mitigation direction for small business lending. Risk mitigation strategies could include implementing collateral requirements, requiring personal guarantees, or recalibrating industry concentration limits.

## Scope
Original time window for the project was FY2000-FY2019. This has been changed to FY2010-2019 since the Small Business Jobs Act of 2010 permanently raised the 7(a) maximum loan size from $2M to $5M, so combining FY2000-2009 with FY2010-2019 would confound any analysis based on loan size. The 2010-2019 period is under consistent regulation and contains both a post-crisis recovery period and an expansionary period. FY2020-CurrentFY is excluded due to a high number of EXEMPT statuses.

## Priors
Overall, my expectation is that larger loan sizes will display higher default rates. I also believe that retail will carry high risk amongst the industries and experience high impact from loan size due to thin margins, high overhead, and fluctuating demand. Grocery stores will display more resilience than specialty stores. Construction is in a gray area; although they are likely to pay slow due to the nature of their work, I have not witnessed many defaults or bankruptcies from companies in this sector. Construction companies also likely correlate loan size with project payout size, so I expect both this industry's impact from loan size and overall default rate to be average.

## Data
SBA FOIA 7(a) loan-level CSV files from https://data.sba.gov/dataset/7-a-504-foia.
File: FY2010-FY2019, as-of date 2025-12-31. ~546k total loans.

## Setup
1. Run sql/01_create_database.sql, sql/02_create_schema.sql, and sql/03_create_table.sql against a local PostgreSQL instance.
2. Create a .env file with DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD.
3. Run scripts/test_connection.py to verify the connection.
4. Place FY2010-FY2019 CSVs in data/raw/.
5. Run scripts/load_CSVs.py.