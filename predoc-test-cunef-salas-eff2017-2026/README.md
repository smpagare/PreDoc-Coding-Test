# CUNEF RA Selection Task: EFF 2017 analysis

Submission for the CUNEF University research assistant selection task, April 2026. Analysis of the Bank of Spain Encuesta Financiera de las Familias (EFF) 2017.

## Context

| Field | Detail |
|-------|--------|
| Institution | CUNEF University, Madrid |
| Contact | Pedro Salas (pedro.salas@cunef.edu) |
| Role | Research Assistant selection task |
| Date completed | April 2026 |
| Language | R |

## Task

The task uses a cleaned version of the EFF 2017 (provided by the PI) and covers six blocks. Paraphrased here; data and the original brief are not redistributed.

1. Multiple imputations and weights. Pool five implicates correctly, demonstrate the unadjusted weight error, compute per implicate weighted means of total net wealth, combine via Rubin's rules.
2. Descriptives on imp == 1. Weighted homeownership rate by five year age groups, by gender split, total wealth by age with bootstrapped CIs, and a reusable plotting function for homeownership rates.
3. Homeownership models. Weighted LPM and an alternative specification for main residence ownership and for second home ownership; compare drivers.
4. Merge and proxy. Merge a second language probability file, build a proxy for internationally exposed higher education, run a weighted LPM for business ownership with average marginal effects by wealth quintile.
5. Constructed variables. Financial wealth share, debt to net wealth ratio, non employment rate. Group comparisons across owners, multi property owners, and renters. Pearson correlation and joint distribution checks.
6. Mortgage holder regressions. Indicator construction, three weighted LPM specifications, LaTeX table output.

## Approach

* Pipeline scripts numbered 00 through 06; `00_master.R` runs the full sequence.
* All weighted statistics use the pooled adjusted weight `facine3 / 5` when implicates are stacked, and `facine3` directly when filtered to `imp == 1`.
* Block 1d uses Rubin's rules across implicates with the `mitools` style decomposition (within and between variance).
* LPMs estimated with `fixest::feols` for speed and consistent standard errors; LPM drawbacks discussed in the report (heteroskedasticity, out of range predictions) and a logit alternative reported alongside.
* Bootstrapped 95% CIs in 2c use 500 resamples within age group.
* AI assistance log saved in `log/`, per the task requirement.

## Files

| File | Purpose |
|------|---------|
| code/00_master.R | Sets paths and packages, sources scripts 01 through 06 |
| code/01_imputations_weights.R | Block 1, weighting and Rubin's rules |
| code/02_descriptive_stats.R | Block 2, weighted descriptives and plotting function |
| code/03_homeownership_models.R | Block 3, weighted LPM and alternative |
| code/04_merge_proxy.R | Block 4, merge with secondlang_prob, proxy LPM |
| code/05_constructed_variables.R | Block 5, constructed variables and group comparisons |
| code/06_mortgage_regressions.R | Block 6, mortgage indicator and three LPMs, LaTeX table |
| report.Rmd | Self contained PDF report with results and interpretation |
| report.pdf | Compiled report submitted to the PI |
| output/figures/ | Saved figures referenced in the report |
| output/tables/ | LaTeX tables referenced in the report |
| log/interaction_log_full.md | AI assistance log, markdown |
| log/interaction_log_full.pdf | AI assistance log, PDF |

## Data and PI materials

The following are not redistributed on GitHub. Available on request from the author:

| File | Description |
|------|-------------|
| `eff.dta` | Cleaned EFF 2017 microdata prepared by the PI. The original survey is published by the Bank of Spain at https://www.bde.es/wbe/en/estadisticas/encuesta-financiera-las-familias-eff/ |
| `secondlang_prob.dta` | Auxiliary file with the probability of speaking a second language by education level, provided by the PI |
| `task_instructions.pdf` | The PI task brief |
| `codebook.pdf` | EFF variable codebook provided by the PI |
| `eff_user_guide_2017.pdf` | EFF user guide provided by the PI |

Anyone with the cleaned `eff.dta` and `secondlang_prob.dta` can rerun the pipeline; results in this repo correspond to the PI cleaned version, not the public Bank of Spain release.

Contact: siddhantpagare2014@gmail.com

## How to reproduce

1. Install R 4.3 or later and the packages loaded in `code/00_master.R` (`haven`, `tidyverse`, `fixest`, `modelsummary`, `boot`, `marginaleffects`, `knitr`, `kableExtra`).
2. Place `eff.dta` and `secondlang_prob.dta` in a folder called `toshare/` at the project root.
3. Open `code/00_master.R`, set `root` to the project root path on your machine, save.
4. Source `code/00_master.R`. The pipeline writes figures and tables into `output/`.
5. Knit `report.Rmd` to produce `report.pdf`.

## Outputs

* `report.pdf`, the deliverable submitted to the PI, with results and interpretation for all six blocks.
* `output/figures/`, individual PDF and PNG figures referenced in the report.
* `output/tables/`, LaTeX tables, including the mortgage regression table for block 6.

## Software

R 4.3.x, RStudio, MacTeX (XeLaTeX for the report).

## Author

Siddhant Manav Pagare, siddhantpagare2014@gmail.com
