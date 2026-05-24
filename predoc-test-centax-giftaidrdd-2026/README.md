# Gift Aid RDD at the £34,600 threshold, CenTax RA test

Submission for the CenTax Research Economist coding test, February 2026. Estimates the effect of the higher rate income threshold on charitable giving via Gift Aid using a regression discontinuity design at the £34,600 earned income cutoff for the 2007 to 2008 UK tax year.

## Context

| Field | Detail |
|-------|--------|
| Institution | CenTax |
| PI | not named in the brief |
| Role | Research Economist coding test |
| Date completed | February 2026 |
| Language | R |

## Task

Paraphrased from the brief; the original is not redistributed.

Using individual level and household level extracts for the 2006 to 2007 baseline year and the 2007 to 2008 treatment year, complete ten steps.

1. Read the three datasets.
2. Merge into a single analytical sample.
3. Graph Gift Aid against earned income and assess the discontinuity at £34,600.
4. Trim the outcome variable and reassess.
5. Construct `us_number`, the count of debt instruments held by the household.
6. Run balance tests on covariates above and below the threshold.
7. Discuss implications of the balance results for the RDD validity.
8. Estimate the RDD model.
9. Re estimate including household debt interaction.
10. Placebo test using the baseline year.

## Approach

* Single R script (`data_analysis.r`) executes all ten tasks sequentially.
* Bandwidth and polynomial order chosen following standard MSE optimal selectors documented in the script.
* Robust standard errors at the individual level; placebo replicates the design at the baseline year where no policy change occurred.
* Outputs saved into `output/`.

## Files

| File | Purpose |
|------|---------|
| data_analysis.r | Main R script covering all ten tasks |
| output/analysis_cleaned.csv | Cleaned analytical sample after the merge and trim |
| output/T3_giftaid_vs_income.png | Gift Aid against earned income, raw data |
| output/T4_giftaid_trimmed_vs_income.png | Gift Aid against earned income after trimming the outcome |

## Data and PI materials

The following are not redistributed on GitHub. Available on request from the author:

| File | Description |
|------|-------------|
| `ind_0607.csv` | Individual level data, baseline year 2006 to 2007, PI provided |
| `ind_0708.csv` | Individual level data, treatment year 2007 to 2008, PI provided |
| `hh_0708.csv` | Household level data, 2007 to 2008, PI provided |

Contact: siddhantpagare2014@gmail.com

## How to reproduce

1. Install R 4.5 or later with `tidyverse` and `ggplot2`.
2. Place `ind_0607.csv`, `ind_0708.csv`, and `hh_0708.csv` in a folder named `data/` at the project root.
3. Open `data_analysis.r`, update the `setwd()` path on the relevant line to point to the project root on your machine, save.
4. Run the script in full. All outputs land in `output/`.

## Outputs

* `output/analysis_cleaned.csv`, the merged and trimmed analytical sample.
* `output/T3_giftaid_vs_income.png` and `T4_giftaid_trimmed_vs_income.png`, the two RDD diagnostic figures.
* RDD point estimates and placebo results are printed to the console; the script can be extended to save these to disk.

## Software

R 4.5.1, RStudio.

## Author

Siddhant Manav Pagare, siddhantpagare2014@gmail.com
