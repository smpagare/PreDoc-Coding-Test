# Gang entry analysis, UChicago Blattman RA test

Submission for the research assistant data exercise from Prof. Chris Blattman, University of Chicago Harris School, January 2026. Analyses youth gang entry decisions in Colombia using baseline survey data, with a recruitment risk construct, prior and posterior income expectations across four occupational groups, and an information treatment.

## Context

| Field | Detail |
|-------|--------|
| Institution | University of Chicago, Harris School of Public Policy |
| PI | Chris Blattman |
| Role | Research Assistant data exercise |
| Date completed | January 2026 |
| Language | R |

## Task

Paraphrased from the PI brief; the original brief is not redistributed.

Using the cleaned baseline survey from the school sample in Colombia, produce four blocks of analysis.

1. Summary statistics. Sample size by survey year, demographic breakdowns by nationality and race, and missingness assessment across the analytical variables.
2. Recruitment risk variable. Construct from clone allocation questions across three scenarios; measure the share of clones allocated to a criminal career (group G4); bucket into low, medium, and high categories.
3. Income expectations. Prior expectations from Section 10A (before the information treatment) and posterior expectations from Section 10B (after the treatment), for four occupational groups: no high school, high school, higher education, and criminal career.
4. Treatment analysis. Restrict to the experimental sample (`formdef_version <= 2309151620`), define treatment via `info_treat == 1`, run balance checks on demographics and recruitment risk, and assess heterogeneous treatment effects by recruitment risk level.

## Approach

* Single R script reads the Stata baseline file, builds the recruitment risk variable from the clone allocations, harmonises the prior and posterior income blocks, and produces all figures and tables.
* Density plots show prior income expectations by occupational group; scatter plots show income and recruitment risk by group.
* Treatment effects estimated as means by treatment status within recruitment risk buckets; balance shown across demographics and the risk variable.
* All decisions documented in `Data_Exercise_Solution_UChicago.pdf`, the writeup submitted to the PI.

## Files

| File | Purpose |
|------|---------|
| Code/data_task_analysis.R | Main analysis script |
| Data_Exercise_Solution_UChicago.pdf | Writeup submitted to the PI |
| Output/figures/density_prior_income_G1.png to G4.png | Prior income densities by occupational group |
| Output/figures/scatter_income_risk_G1.png to G4.png | Income against recruitment risk by group |
| Output/figures/recruitmentrisk_distribution.png | Distribution of the recruitment risk variable |

## Data and PI materials

The following are not redistributed on GitHub. Available on request from the author:

| File | Description |
|------|-------------|
| `0.Data_task.pdf` | The PI task brief |
| `Baseline Survey Questionnaire (SurveyCTO).xlsx` | The SurveyCTO codebook for the survey instrument |
| `Current version of the baseline questionnaire (English).pdf` | The full survey instrument |
| `data_task_1.dta` | Cleaned baseline survey microdata in Stata format, prepared by the PI |

Contact: siddhantpagare2014@gmail.com

## How to reproduce

1. Install R 4.3 or later with `haven`, `tidyverse`, `ggplot2`, and `stargazer` or `kableExtra`.
2. Place `data_task_1.dta` in a folder named `Raw Data/` at the project root.
3. Open `Code/data_task_analysis.R`, set the working directory to the project root, save.
4. Source the script. Outputs land in `Output/figures/` and `Output/tables/`.

## Outputs

* `Data_Exercise_Solution_UChicago.pdf`, the deliverable PDF submitted to the PI.
* `Output/figures/`, the saved figures referenced in the writeup.

## Software

R 4.3.x, RStudio.

## Author

Siddhant Manav Pagare, siddhantpagare2014@gmail.com
