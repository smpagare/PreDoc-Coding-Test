# Master script - Encuesta Financiera de las Familias
# Siddhant Manav Pagare

library(haven)
library(tidyverse)
library(fixest)
library(modelsummary)
library(boot)
library(marginaleffects)

# Paths
root     <- "/Users/sid/Desktop/Git/cunef rojo"
data_dir <- file.path(root, "toshare")
fig_dir  <- file.path(root, "output", "figures")
tab_dir  <- file.path(root, "output", "tables")
log_dir  <- file.path(root, "log")

# Load data
eff  <- read_dta(file.path(data_dir, "eff.dta"))
lang <- read_dta(file.path(data_dir, "secondlang_prob.dta"))

# Run analysis scripts
source(file.path(root, "code", "01_imputations_weights.R"))
source(file.path(root, "code", "02_descriptive_stats.R"))
source(file.path(root, "code", "03_homeownership_models.R"))
source(file.path(root, "code", "04_merge_proxy.R"))
source(file.path(root, "code", "05_constructed_variables.R"))
source(file.path(root, "code", "06_mortgage_regressions.R"))
