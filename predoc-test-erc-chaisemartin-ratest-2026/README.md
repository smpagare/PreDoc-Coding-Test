# ERC Really Credible RA test: dynamic DiD, Monte Carlo, and package questions

Submission for the ERC Really Credible research assistant selection test, May 2026. Covers four of seven exercises: a Monte Carlo on method of moments versus maximum likelihood estimators, a dynamic difference in differences replication of Burgess et al. (2015) using `did_multiplegt_dyn`, two user question diagnoses, and a review of a commit on the `did_multiplegt_dyn` package.

## Context

| Field | Detail |
|-------|--------|
| Institution | ERC Really Credible (de Chaisemartin ERC grant) |
| Contact | Clément de Chaisemartin, chaisemartin.packages@gmail.com |
| Role | Research Assistant selection task |
| Date completed | May 2026 |
| Languages | Stata, R, LaTeX |

## Task

The test asks the candidate to complete four of seven exercises, with at least one of the two math exercises (1 or 2). Paraphrased; the original brief and PI provided materials are not redistributed here.

* Exercise 1: For an iid uniform sample on `[0, theta]`, derive the method of moments and maximum likelihood estimators, study their asymptotic behaviour, run a Monte Carlo to compare finite sample properties, and build a confidence interval using the better estimator.
* Exercise 3: Replicate the main two way fixed effects specification in Burgess et al. (2015) on ethnic favouritism in Kenyan road building, then estimate dynamic treatment effects of presidential coethnicity using `did_multiplegt_dyn`.
* Exercise 6: Diagnose two user questions on the `did_multiplegt_dyn` package and write up the resolution.
* Exercise 7: Review a specific commit (`b3849a3`) and issue 72 on the package repository, summarise the change, and assess its correctness.

## Approach

* Exercise 1. Closed form derivations for bias and variance of the MM and ML estimators, asymptotic distribution arguments for both estimators (CLT for MM, max of uniforms for ML), Stata Monte Carlo with sample sizes 25, 100, 400, 1600 across 10,000 replications. CIs constructed using the ML pivot.
* Exercise 3. Cleaned the district year panel from 1963 to 2011, recoded coethnicity to the treatment indicator, estimated the TWFE benchmark, then ran `did_multiplegt_dyn` with seven post and three pre periods, plotted event study coefficients with 95% CIs, and assessed dynamic patterns under autocracy.
* Exercise 6. Read the relevant theorems from de Chaisemartin and D'Haultfoeuille 2023 and 2024 to ground the answers, traced the user questions to the underlying assumption set, and produced reproducible minimal examples.
* Exercise 7. Read commit `b3849a3` and the surrounding diff line by line, cross checked against the documented behaviour in the help file, and assessed whether the change fixed the issue reported in issue 72.
* AI use. Claude (Anthropic) was used as a syntax assistant for the Stata Monte Carlo loop in Exercise 1 and as a LaTeX drafting aide. Mathematical derivations, the Exercise 3 design, the Exercise 6 diagnoses, and the Exercise 7 commit review are mine. A clean transcript of the Exercise 1 AI exchange is in `ai_transcripts/`.

## Files

| File | Purpose |
|------|---------|
| main_report.tex | LaTeX root, pulls in each exercise writeup |
| main_report.pdf | Compiled report submitted to the PI |
| refs.bib | Bibliography |
| exercise1/solution.tex | Writeup for exercise 1 |
| exercise1/monte_carlo.do | Stata Monte Carlo for MM vs ML |
| exercise1/ex1_ml_exp.pdf | ML estimator sampling distribution plot |
| exercise1/ex1_mm_clt.pdf | MM estimator CLT illustration |
| exercise3/writeup.tex | Writeup for exercise 3 |
| exercise3/analysis.R | R script for the Burgess replication and dynamic DiD |
| exercise3/output/ex3_horizons.csv | Event study coefficients table |
| exercise3/output/ex3_part1_event.pdf | TWFE benchmark event study |
| exercise3/output/ex3_part2a_event.pdf | `did_multiplegt_dyn` event study |
| exercise3/output/ex3_part2b_event.pdf | Heterogeneity by political regime |
| exercise6/answers.tex | Writeup for exercise 6 |
| exercise7/commit_review.tex | Writeup for exercise 7 |
| ai_transcripts/exercise1_monte_carlo.md | AI assistance log for exercise 1 |

## Data and PI materials

The following are not redistributed on GitHub. Available on request from the author:

| File | Description |
|------|-------------|
| `Task_MAIN_source.pdf` | The PI task brief |
| `test_RAs_math_1.pdf` | Math exercise statement 1 (PI provided) |
| `test_RAs_math_2.pdf` | Math exercise statement 2 (PI provided) |
| `exercise3_data.dta` | District year panel for Kenya 1963 to 2011, PI curated extract derived from Burgess et al. 2015 |
| `Papers/` (6 PDFs) | PI curated reference papers: Burgess et al. 2015, de Chaisemartin and D'Haultfoeuille 2023 and 2024, and three further working papers |

The Burgess et al. 2015 dataset and the cited working papers are publicly accessible from the original publishers; the files used here are the PI curated copies, which is why they are not committed.

Contact: siddhantpagare2014@gmail.com

## How to reproduce

1. Install R 4.3 or later (`tidyverse`, `haven`, `fixest`, `ggplot2`) and Stata 17 or later with the `did_multiplegt_dyn` package installed via `ssc install did_multiplegt_dyn`.
2. Obtain `exercise3_data.dta` from the original PI brief or from the Burgess et al. 2015 replication package; place it in a folder named `TestRA copy/` at the project root.
3. For Exercise 1, open `exercise1/monte_carlo.do` and run in Stata; figures are written next to the script.
4. For Exercise 3, open `exercise3/analysis.R`, set the working directory to the project root, and source the file. Outputs land in `exercise3/output/`.
5. Compile `main_report.tex` with `latexmk -xelatex main_report.tex` to produce `main_report.pdf`.

## Outputs

* `main_report.pdf`, the deliverable PDF submitted to the PI, with all four exercises and the AI use statement.
* `exercise1/ex1_*.pdf`, sampling distribution plots from the Monte Carlo.
* `exercise3/output/`, event study coefficients and figures for the Burgess replication and the dynamic DiD.

## Software

R 4.3.x, Stata 17, MacTeX (XeLaTeX), `did_multiplegt_dyn` Stata package.

## Author

Siddhant Manav Pagare, siddhantpagare2014@gmail.com
