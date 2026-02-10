# Data Exercise: Gang Entry Analysis

**UChicago Candidate Evaluation Task**
January 2026

## Overview

This project analyzes factors related to gang entry decisions among youth in Colombia, based on research by Prof. Blattman. The analysis examines recruitment risk, income expectations, and the effects of an information treatment experiment.

## Project Structure

```
Task 1 documents/
├── Code/
│   └── data_task_analysis.R      # Main analysis script
├── Output/
│   ├── figures/                  # Generated plots and visualizations
│   └── tables/                   # Summary statistics and regression tables
├── Raw Data/
│   └── data_task_1.dta           # Primary dataset (Stata format)
├── 0.Data_task.pdf               # Task instructions
├── Baseline Survey Questionnaire (SurveyCTO).xlsx  # Variable codebook
├── 2023-07-06. Current version of the baseline questionnaire (English).pdf  # Survey instrument
└── Data_Exercise_Solution_UChicago.pdf  # Solution document
```

## Data Description

- **Source**: Baseline survey data from school surveys in Colombia
- **Format**: Stata (.dta) file
- **Key Variables**:
  - Demographics (nationality, race, age)
  - Survey metadata (instance_time, formdef_version)
  - Occupational group clone allocations (EOI variables)
  - Income expectations (EIA/EIF variables)
  - Treatment indicators (stcs_stroy_lab, info_treat)

## Analysis Tasks

### 1. Summary Statistics
- Sample size and survey year distribution
- Demographic breakdowns (nationality, race)
- Missingness assessment

### 2. Recruitment Risk Variable
- Constructed from clone allocation questions across 3 scenarios
- Measures share of clones allocated to criminal career (G4)
- Categories: Low [0, 0.2), Medium [0.2, 0.3), High [0.3, 1]

### 3. Income Expectations
- Prior expectations (Section 10A - before information treatment)
- Posterior expectations (Section 10B - after treatment)
- Four occupational groups: G1 (no HS), G2 (HS), G3 (higher ed), G4 (criminal)

### 4. Treatment Analysis
- Experiment defined by formdef_version <= 2309151620
- Information treatment: info_treat == 1
- Balance checks on demographics and recruitment risk
- Heterogeneity analysis by recruitment risk level

## Reproducing the Analysis

1. Ensure R is installed with required packages:
   - `haven` (reading Stata files)
   - `tidyverse` (data manipulation and visualization)
   - `ggplot2` (plots)
   - `stargazer` or `kableExtra` (tables)

2. Run the analysis script:
   ```r
   source("Code/data_task_analysis.R")
   ```

3. Outputs will be saved to `Output/figures/` and `Output/tables/`

## Key Findings

See `Data_Exercise_Solution_UChicago.pdf` for complete analysis results.

## References

- Blattman, C. - Research on gang entry and youth decision-making
- Survey instrument: Baseline questionnaire (English version)
- Variable definitions: SurveyCTO codebook
