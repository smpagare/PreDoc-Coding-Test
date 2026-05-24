# ==============================================================================
# Data Exercise - Gang Entry Task
# R Code Solution
# ==============================================================================
# This script analyzes survey data on gang entry decisions among youth.
# The analysis covers:
#   - Section 1.1: Basic summary statistics
#   - Section 1.2: Creating recruitmentrisk variable
#   - Section 1.3: Creating prior and posterior income expectations
#   - Section 1.4: Recruitment risk and mean income priors correlation
#   - Section 1.5: Creating treatment variable
#   - Section 1.6: Balance table
#   - Section 1.7: Information treatment analysis
# ==============================================================================

# Clear environment
rm(list = ls())

# ==============================================================================
# SETUP: Load Required Packages
# ==============================================================================

packages <- c("haven", "tidyverse", "ggplot2", "knitr", "kableExtra",
              "stargazer", "modelsummary", "fixest", "scales", "lubridate")

installed_packages <- packages %in% rownames(installed.packages())
if (any(!installed_packages)) {
  install.packages(packages[!installed_packages])
}

library(haven)
library(tidyverse)
library(ggplot2)
library(knitr)
library(scales)
library(lubridate)

# Set working directory
setwd("/Users/sid/Desktop/UChicago/Task 1 documents")

# Create output directories
if (!dir.exists("output")) dir.create("output")
if (!dir.exists("output/tables")) dir.create("output/tables")

# ==============================================================================
# LOAD DATA
# ==============================================================================

df <- read_dta("data_task_1.dta")

# ==============================================================================
# SECTION 1.1: BASIC SUMMARY STATISTICS
# ==============================================================================
# TASK: Provide summary statistics on N, survey year, nationality, and race.
# Report missingness if present.

# ---------- ANSWER 1.1.1: Number of surveys ----------
n_surveys <- nrow(df)
n_surveys  # Display result

# ---------- ANSWER 1.1.2: Survey year ----------
# Construct survey_year from instance_time (format: "YYYY-MM-DD HH-MM")
df <- df %>%
  mutate(
    instance_time_parsed = gsub("(\\d{4}-\\d{2}-\\d{2}) (\\d{2})-(\\d{2})",
                                 "\\1 \\2:\\3", instance_time),
    survey_year = year(ymd_hm(instance_time_parsed))
  )

survey_year_table <- df %>%
  count(survey_year) %>%
  mutate(percent = round(n / sum(n) * 100, 2))
survey_year_table  # Display result

missing_year <- sum(is.na(df$survey_year))
missing_year  # Missing count

# ---------- ANSWER 1.1.3: Nationality ----------
nationality_table <- df %>%
  count(birthcountry) %>%
  mutate(percent = round(n / sum(n) * 100, 2)) %>%
  arrange(desc(n))
nationality_table  # Display result

missing_nationality <- sum(is.na(df$birthcountry))
missing_nationality  # Missing count

# ---------- ANSWER 1.1.4: Race ----------
race_table <- df %>%
  count(race) %>%
  mutate(percent = round(n / sum(n) * 100, 2)) %>%
  arrange(desc(n))
race_table  # Display result

missing_race <- sum(is.na(df$race))
missing_race  # Missing count

# Additional: Survey duration
df$duration_mins <- df$duration / 60
summary(df$duration_mins)

# ==============================================================================
# SECTION 1.2: CREATING RECRUITMENTRISK VARIABLE
# ==============================================================================
# TASK: Create recruitmentrisk as the share of clones put in G4 across 3 questions.
#
# METHODOLOGY:
# - Kids distribute 10 clones across occupational groups in 3 rounds:
#   Q1: All 4 groups (G1, G2, G3, G4) - variable: interest_job_g4
#   Q2: G3 dropped (G1, G2, G4) - variable: interest_job_g4_2
#   Q3: G2 dropped (G1, G4) - variable: interest_job_g4_3
# - Total possible clones across 3 questions = 30
# - recruitmentrisk = sum(G4 clones) / 30

df <- df %>%
  mutate(
    total_g4_clones = interest_job_g4 + interest_job_g4_2 + interest_job_g4_3,
    recruitmentrisk = total_g4_clones / 30
  )

# ---------- ANSWER 1.2.3: Summary statistics table ----------
recruitmentrisk_stats <- df %>%
  summarise(
    N = sum(!is.na(recruitmentrisk)),
    Missing = sum(is.na(recruitmentrisk)),
    Mean = mean(recruitmentrisk, na.rm = TRUE),
    SD = sd(recruitmentrisk, na.rm = TRUE),
    Min = min(recruitmentrisk, na.rm = TRUE),
    Q1 = quantile(recruitmentrisk, 0.25, na.rm = TRUE),
    Median = quantile(recruitmentrisk, 0.50, na.rm = TRUE),
    Q3 = quantile(recruitmentrisk, 0.75, na.rm = TRUE),
    P90 = quantile(recruitmentrisk, 0.90, na.rm = TRUE),
    P99 = quantile(recruitmentrisk, 0.99, na.rm = TRUE),
    Max = max(recruitmentrisk, na.rm = TRUE)
  )
recruitmentrisk_stats  # Display result

write.csv(recruitmentrisk_stats, "output/tables/recruitmentrisk_summary.csv", row.names = FALSE)

# ---------- ANSWER 1.2.4: Histogram/density plot ----------
mean_rr <- mean(df$recruitmentrisk, na.rm = TRUE)
median_rr <- median(df$recruitmentrisk, na.rm = TRUE)

ref_df <- data.frame(
  stat = c("Mean", "Median"),
  value = c(mean_rr, median_rr)
)

p1 <- ggplot(df, aes(x = recruitmentrisk)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30, fill = "steelblue",
                 color = "white", alpha = 0.7) +
  geom_density(color = "darkred", linewidth = 1) +
  geom_vline(data = ref_df, aes(xintercept = value, color = stat, linetype = stat),
             linewidth = 1) +
  scale_color_manual(
    name = "Summary statistics",
    values = c("Mean" = "red", "Median" = "blue"),
    labels = c(paste0("Mean = ", round(mean_rr, 3)),
               paste0("Median = ", round(median_rr, 3)))
  ) +
  scale_linetype_manual(name = "Summary statistics",
                        values = c("Mean" = "dashed", "Median" = "dotted"),
                        guide = "none") +
  labs(title = "Distribution of Recruitment Risk",
       subtitle = "Share of clones allocated to criminal career (G4) across 3 questions",
       x = "Recruitment Risk", y = "Density") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold"),
        legend.position = "top")

p1  # Display plot
ggsave("output/figures/recruitmentrisk_distribution.png", p1, width = 10, height = 6, dpi = 300)

# ==============================================================================
# SECTION 1.3: CREATING PRIOR AND POSTERIOR INCOME EXPECTATIONS
# ==============================================================================
# TASK: Create prior and posterior mean income variables for G1, G2, G3, G4.
#
# METHODOLOGY:
# Income expectations are elicited via probability distribution questions.
# Respondents distribute 10 tokens across 5 income bins (Q1-Q5).
# Mean expected income is calculated as:
#   E[Income] = Sum(Probability_i * Midpoint_i) / Sum(Probability_i)
#
# INCOME BINS FROM QUESTIONNAIRE (Section 10A - Colombian Pesos):
# ------------------------------------------------------------------------------
#   Q1: $0 - $1,000,000 COP           -> Midpoint = $500,000 COP
#   Q2: $1,000,001 - $2,000,000 COP   -> Midpoint = $1,500,000 COP
#   Q3: $2,000,001 - $3,000,000 COP   -> Midpoint = $2,500,000 COP
#   Q4: $3,000,001 - $4,000,000 COP   -> Midpoint = $3,500,000 COP
#   Q5: More than $4,000,000 COP      -> Midpoint = varies (sensitivity analysis)
# ------------------------------------------------------------------------------
#
# SENSITIVITY ANALYSIS FOR Q5:
# Since Q5 is open-ended, we test three assumptions: 5M, 6M, 8M COP
#
# VARIABLE NAMING:
#   Prior (Section 10A - average person): income23_avg_q[1-5]_g[1-4]
#   Posterior (Section 10B - friends):    income23_q[1-5]_g[1-4]
#
# GROUPS:
#   G1 = No high school diploma
#   G2 = High school diploma
#   G3 = Higher education (college/university)
#   G4 = Criminal activity

# Define midpoints for income bins (Colombian pesos)
midpoint_q1 <- 500000      # Q1: $0 - $1,000,000 COP
midpoint_q2 <- 1500000     # Q2: $1,000,001 - $2,000,000 COP
midpoint_q3 <- 2500000     # Q3: $2,000,001 - $3,000,000 COP
midpoint_q4 <- 3500000     # Q4: $3,000,001 - $4,000,000 COP

# Q5 midpoint assumptions for sensitivity analysis
q5_assumptions <- c(5000000, 6000000, 8000000)

# Compute probability sums for normalization
df <- df %>%
  mutate(
    # Prior probability sums (Section 10A)
    prior_sum_g1 = income23_avg_q1_g1 + income23_avg_q2_g1 + income23_avg_q3_g1 +
                   income23_avg_q4_g1 + income23_avg_q5_g1,
    prior_sum_g2 = income23_avg_q1_g2 + income23_avg_q2_g2 + income23_avg_q3_g2 +
                   income23_avg_q4_g2 + income23_avg_q5_g2,
    prior_sum_g3 = income23_avg_q1_g3 + income23_avg_q2_g3 + income23_avg_q3_g3 +
                   income23_avg_q4_g3 + income23_avg_q5_g3,
    prior_sum_g4 = income23_avg_q1_g4 + income23_avg_q2_g4 + income23_avg_q3_g4 +
                   income23_avg_q4_g4 + income23_avg_q5_g4,
    # Posterior probability sums (Section 10B)
    posterior_sum_g1 = income23_q1_g1 + income23_q2_g1 + income23_q3_g1 +
                       income23_q4_g1 + income23_q5_g1,
    posterior_sum_g2 = income23_q1_g2 + income23_q2_g2 + income23_q3_g2 +
                       income23_q4_g2 + income23_q5_g2,
    posterior_sum_g3 = income23_q1_g3 + income23_q2_g3 + income23_q3_g3 +
                       income23_q4_g3 + income23_q5_g3,
    posterior_sum_g4 = income23_q1_g4 + income23_q2_g4 + income23_q3_g4 +
                       income23_q4_g4 + income23_q5_g4
  )

# Function to compute income expectations
compute_income_expectations <- function(data, midpoint_q5) {
  data %>%
    mutate(
      # PRIOR (Section 10A - Average Person)
      prior_mean_income_g1 = (income23_avg_q1_g1 * midpoint_q1 +
                              income23_avg_q2_g1 * midpoint_q2 +
                              income23_avg_q3_g1 * midpoint_q3 +
                              income23_avg_q4_g1 * midpoint_q4 +
                              income23_avg_q5_g1 * midpoint_q5) / prior_sum_g1,
      prior_mean_income_g2 = (income23_avg_q1_g2 * midpoint_q1 +
                              income23_avg_q2_g2 * midpoint_q2 +
                              income23_avg_q3_g2 * midpoint_q3 +
                              income23_avg_q4_g2 * midpoint_q4 +
                              income23_avg_q5_g2 * midpoint_q5) / prior_sum_g2,
      prior_mean_income_g3 = (income23_avg_q1_g3 * midpoint_q1 +
                              income23_avg_q2_g3 * midpoint_q2 +
                              income23_avg_q3_g3 * midpoint_q3 +
                              income23_avg_q4_g3 * midpoint_q4 +
                              income23_avg_q5_g3 * midpoint_q5) / prior_sum_g3,
      prior_mean_income_g4 = (income23_avg_q1_g4 * midpoint_q1 +
                              income23_avg_q2_g4 * midpoint_q2 +
                              income23_avg_q3_g4 * midpoint_q3 +
                              income23_avg_q4_g4 * midpoint_q4 +
                              income23_avg_q5_g4 * midpoint_q5) / prior_sum_g4,
      # POSTERIOR (Section 10B - Friends)
      posterior_mean_income_g1 = (income23_q1_g1 * midpoint_q1 +
                                  income23_q2_g1 * midpoint_q2 +
                                  income23_q3_g1 * midpoint_q3 +
                                  income23_q4_g1 * midpoint_q4 +
                                  income23_q5_g1 * midpoint_q5) / posterior_sum_g1,
      posterior_mean_income_g2 = (income23_q1_g2 * midpoint_q1 +
                                  income23_q2_g2 * midpoint_q2 +
                                  income23_q3_g2 * midpoint_q3 +
                                  income23_q4_g2 * midpoint_q4 +
                                  income23_q5_g2 * midpoint_q5) / posterior_sum_g2,
      posterior_mean_income_g3 = (income23_q1_g3 * midpoint_q1 +
                                  income23_q2_g3 * midpoint_q2 +
                                  income23_q3_g3 * midpoint_q3 +
                                  income23_q4_g3 * midpoint_q4 +
                                  income23_q5_g3 * midpoint_q5) / posterior_sum_g3,
      posterior_mean_income_g4 = (income23_q1_g4 * midpoint_q1 +
                                  income23_q2_g4 * midpoint_q2 +
                                  income23_q3_g4 * midpoint_q3 +
                                  income23_q4_g4 * midpoint_q4 +
                                  income23_q5_g4 * midpoint_q5) / posterior_sum_g4
    )
}

# ---------- SENSITIVITY ANALYSIS ----------
# Initialize vectors to store results directly (avoid tibble extraction issues)
prior_g1 <- prior_g2 <- prior_g3 <- prior_g4 <- numeric(3)
post_g1 <- post_g2 <- post_g3 <- post_g4 <- numeric(3)

for (i in seq_along(q5_assumptions)) {
  midpoint_q5 <- q5_assumptions[i]
  df_temp <- compute_income_expectations(df, midpoint_q5)

  # Store results directly in vectors using base R mean()
  prior_g1[i] <- mean(df_temp$prior_mean_income_g1, na.rm = TRUE)
  prior_g2[i] <- mean(df_temp$prior_mean_income_g2, na.rm = TRUE)
  prior_g3[i] <- mean(df_temp$prior_mean_income_g3, na.rm = TRUE)
  prior_g4[i] <- mean(df_temp$prior_mean_income_g4, na.rm = TRUE)

  post_g1[i] <- mean(df_temp$posterior_mean_income_g1, na.rm = TRUE)
  post_g2[i] <- mean(df_temp$posterior_mean_income_g2, na.rm = TRUE)
  post_g3[i] <- mean(df_temp$posterior_mean_income_g3, na.rm = TRUE)
  post_g4[i] <- mean(df_temp$posterior_mean_income_g4, na.rm = TRUE)
}

# ---------- ANSWER 1.3: Create and display sensitivity analysis table ----------
# Create table for Prior results (Q5 = 5M, 6M, 8M are indices 1, 2, 3)
prior_sensitivity <- data.frame(
  Group = c("G1 (No HS)", "G2 (HS)", "G3 (Higher Ed)", "G4 (Criminal)"),
  Q5_5M = c(prior_g1[1], prior_g2[1], prior_g3[1], prior_g4[1]),
  Q5_6M = c(prior_g1[2], prior_g2[2], prior_g3[2], prior_g4[2]),
  Q5_8M = c(prior_g1[3], prior_g2[3], prior_g3[3], prior_g4[3])
)

# Create table for Posterior results
posterior_sensitivity <- data.frame(
  Group = c("G1 (No HS)", "G2 (HS)", "G3 (Higher Ed)", "G4 (Criminal)"),
  Q5_5M = c(post_g1[1], post_g2[1], post_g3[1], post_g4[1]),
  Q5_6M = c(post_g1[2], post_g2[2], post_g3[2], post_g4[2]),
  Q5_8M = c(post_g1[3], post_g2[3], post_g3[3], post_g4[3])
)

# Display results
"PRIOR Mean Income Expectations by Q5 Assumption (COP):"
prior_sensitivity

"POSTERIOR Mean Income Expectations by Q5 Assumption (COP):"
posterior_sensitivity

# Combine and save
sensitivity_table <- rbind(
  cbind(time = "Prior", prior_sensitivity),
  cbind(time = "Posterior", posterior_sensitivity)
)
names(sensitivity_table) <- c("time", "Group", "Q5=5M", "Q5=6M", "Q5=8M")
write.csv(sensitivity_table, "output/tables/sensitivity_analysis_income.csv", row.names = FALSE)

# Apply baseline Q5 assumption (5M COP) to main dataframe
midpoint_q5 <- 5000000
df <- compute_income_expectations(df, midpoint_q5)

# ==============================================================================
# SECTION 1.4: RECRUITMENT RISK AND MEAN INCOME PRIORS
# ==============================================================================
# TASK: Examine correlation between recruitment risk and income expectations.

# ---------- ANSWER 1.4.1: Create recruitmentrisk_top_lab ----------
df <- df %>%
  mutate(
    recruitmentrisk_top_lab = case_when(
      recruitmentrisk >= 0 & recruitmentrisk < 0.2 ~ "Low",
      recruitmentrisk >= 0.2 & recruitmentrisk < 0.3 ~ "Medium",
      recruitmentrisk >= 0.3 & recruitmentrisk <= 1 ~ "High",
      TRUE ~ NA_character_
    ),
    recruitmentrisk_top_lab = factor(recruitmentrisk_top_lab,
                                      levels = c("Low", "Medium", "High"))
  )

# Display distribution
table(df$recruitmentrisk_top_lab, useNA = "ifany")

# ---------- ANSWER 1.4.2: Density plots using for loop ----------
group_names <- c("G1", "G2", "G3", "G4")
income_vars <- c("prior_mean_income_g1", "prior_mean_income_g2",
                 "prior_mean_income_g3", "prior_mean_income_g4")
group_labels <- c("G1: No High School", "G2: High School",
                  "G3: Higher Education", "G4: Criminal Career")

# Calculate means by recruitment risk category
means_by_risk <- df %>%
  filter(!is.na(recruitmentrisk_top_lab)) %>%
  group_by(recruitmentrisk_top_lab) %>%
  summarise(
    mean_g1 = mean(prior_mean_income_g1, na.rm = TRUE),
    mean_g2 = mean(prior_mean_income_g2, na.rm = TRUE),
    mean_g3 = mean(prior_mean_income_g3, na.rm = TRUE),
    mean_g4 = mean(prior_mean_income_g4, na.rm = TRUE)
  )

for (i in 1:4) {
  income_var <- income_vars[i]
  group_label <- group_labels[i]
  group_name <- group_names[i]

  means_for_plot <- means_by_risk %>%
    select(recruitmentrisk_top_lab, paste0("mean_g", i)) %>%
    rename(mean_income = 2)

  p <- ggplot(df %>% filter(!is.na(recruitmentrisk_top_lab) & !is.na(.data[[income_var]])),
              aes(x = .data[[income_var]], fill = recruitmentrisk_top_lab,
                  color = recruitmentrisk_top_lab)) +
    geom_density(alpha = 0.3, linewidth = 1) +
    geom_vline(data = means_for_plot,
               aes(xintercept = mean_income, color = recruitmentrisk_top_lab),
               linetype = "dashed", linewidth = 1) +
    scale_x_continuous(labels = label_comma()) +
    scale_fill_manual(values = c("Low" = "green", "Medium" = "orange", "High" = "red")) +
    scale_color_manual(values = c("Low" = "darkgreen", "Medium" = "darkorange", "High" = "darkred")) +
    labs(title = paste("Prior Mean Income Expectations -", group_label),
         subtitle = "By Recruitment Risk Category (vertical lines = group means)",
         x = "Mean Expected Income (COP)", y = "Density",
         fill = "Recruitment Risk", color = "Recruitment Risk") +
    theme_minimal() +
    theme(plot.title = element_text(face = "bold"), legend.position = "bottom")

  print(p)  # Display plot
  ggsave(paste0("output/figures/density_prior_income_", group_name, ".png"), p,
         width = 10, height = 6, dpi = 300)
}

# ---------- ANSWER 1.4.3: Scatter plots with regression lines ----------
for (i in 1:4) {
  income_var <- income_vars[i]
  group_label <- group_labels[i]
  group_name <- group_names[i]

  p <- ggplot(df %>% filter(!is.na(recruitmentrisk) & !is.na(.data[[income_var]])),
              aes(x = recruitmentrisk, y = .data[[income_var]])) +
    geom_point(alpha = 0.3, color = "steelblue") +
    geom_smooth(method = "lm", color = "red", se = TRUE) +
    scale_y_continuous(labels = label_comma()) +
    labs(title = paste("Prior Income vs. Recruitment Risk -", group_label),
         x = "Recruitment Risk", y = "Mean Expected Income (COP)") +
    theme_minimal() +
    theme(plot.title = element_text(face = "bold"))

  print(p)  # Display plot
  ggsave(paste0("output/figures/scatter_income_risk_", group_name, ".png"), p,
         width = 10, height = 6, dpi = 300)
}

# ---------- ANSWER 1.4.4: Correlations ----------
correlations_df <- data.frame(
  Group = c("G1 (No HS)", "G2 (HS)", "G3 (Higher Ed)", "G4 (Criminal)"),
  Correlation = c(
    cor(df$recruitmentrisk, df$prior_mean_income_g1, use = "complete.obs"),
    cor(df$recruitmentrisk, df$prior_mean_income_g2, use = "complete.obs"),
    cor(df$recruitmentrisk, df$prior_mean_income_g3, use = "complete.obs"),
    cor(df$recruitmentrisk, df$prior_mean_income_g4, use = "complete.obs")
  )
)
"Correlations between recruitment risk and prior income expectations:"
correlations_df

# ==============================================================================
# SECTION 1.5: CREATE TREATMENT VARIABLE
# ==============================================================================
# TASK: Create info_treat variable for information treatment experiment.

# ---------- ANSWER 1.5.1: Table of stcs_stroy_lab values ----------
stcs_table <- df %>%
  count(stcs_stroy_lab) %>%
  mutate(percent = round(n / sum(n) * 100, 2))
"Values of stcs_stroy_lab:"
stcs_table

# ---------- ANSWER 1.5.2: Create experiment1 variable ----------
# experiment1 = 1 if formdef_version <= 2309151620 (first experiment)
df <- df %>%
  mutate(experiment1 = ifelse(formdef_version <= 2309151620, 1, 0))

"Experiment1 distribution:"
table(df$experiment1)

# Distribution within experiment1
exp1_stcs <- df %>%
  filter(experiment1 == 1) %>%
  count(stcs_stroy_lab) %>%
  mutate(percent = round(n / sum(n) * 100, 2))
"stcs_stroy_lab within experiment1 == 1:"
exp1_stcs

# ---------- ANSWER 1.5.3: Create info_treat variable ----------
# info_treat = 0 for Control, = 1 for information treatment (Estadistica variants)
# Video and Historia are excluded (non-pecuniary treatments)
df <- df %>%
  mutate(
    info_treat = case_when(
      stcs_stroy_lab == "Control" ~ 0,
      grepl("Estad", stcs_stroy_lab) ~ 1,
      TRUE ~ NA_real_
    )
  )

"Treatment assignment (info_treat):"
table(df$info_treat, useNA = "ifany")

# ==============================================================================
# SECTION 1.6: CHECK BALANCE
# ==============================================================================
# TASK: Create balance table for experiment1 == 1 subset.
# Note: Keep full dataset, only analyze experiment1 == 1 subset.

df_exp1 <- df %>% filter(experiment1 == 1)
df_balance <- df_exp1 %>% filter(!is.na(info_treat))

"Sample size for balance analysis:"
nrow(df_balance)

# Helper function for balance statistics
calc_balance <- function(data, var_name) {
  stats <- data %>%
    group_by(info_treat) %>%
    summarise(
      mean = mean(.data[[var_name]], na.rm = TRUE),
      sd = sd(.data[[var_name]], na.rm = TRUE),
      n = sum(!is.na(.data[[var_name]])),
      .groups = "drop"
    )

  treated <- data %>% filter(info_treat == 1) %>% pull(var_name)
  control <- data %>% filter(info_treat == 0) %>% pull(var_name)
  ttest_p <- tryCatch(t.test(treated, control)$p.value, error = function(e) NA)

  list(
    control_mean = stats$mean[stats$info_treat == 0],
    control_sd = stats$sd[stats$info_treat == 0],
    treated_mean = stats$mean[stats$info_treat == 1],
    treated_sd = stats$sd[stats$info_treat == 1],
    diff = stats$mean[stats$info_treat == 1] - stats$mean[stats$info_treat == 0],
    p_value = ttest_p
  )
}

# ---------- ANSWER 1.6: Balance Table ----------
bal_rr <- calc_balance(df_balance, "recruitmentrisk")
bal_hh <- calc_balance(df_balance, "household_num")
bal_inc <- calc_balance(df_balance, "prior_mean_income_g3")

n_control <- sum(df_balance$info_treat == 0)
n_treated <- sum(df_balance$info_treat == 1)

balance_table <- data.frame(
  Variable = c("Recruitment Risk", "Household Size", "Prior Income G3", "N"),
  Control_Mean = c(bal_rr$control_mean, bal_hh$control_mean, bal_inc$control_mean, n_control),
  Control_SD = c(bal_rr$control_sd, bal_hh$control_sd, bal_inc$control_sd, NA),
  Treated_Mean = c(bal_rr$treated_mean, bal_hh$treated_mean, bal_inc$treated_mean, n_treated),
  Treated_SD = c(bal_rr$treated_sd, bal_hh$treated_sd, bal_inc$treated_sd, NA),
  Difference = c(bal_rr$diff, bal_hh$diff, bal_inc$diff, NA),
  P_Value = c(bal_rr$p_value, bal_hh$p_value, bal_inc$p_value, NA)
)

"BALANCE TABLE:"
balance_table

write.csv(balance_table, "output/tables/balance_table.csv", row.names = FALSE)

# ==============================================================================
# SECTION 1.7: INFORMATION TREATMENT ANALYSIS
# ==============================================================================
# TASK: Analyze how kids respond to information treatment on G3 income.
#
# METHODOLOGY:
# 1. Create g3_prior_error = prior_mean_income_g3 - 3,000,000 (true mean)
# 2. Create g3_revision = posterior - prior (belief update)
# 3. Estimate treatment effects using OLS regression
#
# REGRESSION EQUATION:
#   g3_revision = beta0 + beta1*info_treat + beta2*g3_prior_error
#                 + beta3*(info_treat * g3_prior_error) + epsilon
#
# - beta1: Main treatment effect (ATE)
# - beta2: How prior error relates to revision (for control group)
# - beta3: Heterogeneous treatment effect by prior error

# ---------- ANSWER 1.7.1: Create g3_prior_error variable ----------
df <- df %>%
  mutate(
    g3_prior_error = prior_mean_income_g3 - 3000000,
    g3_revision = posterior_mean_income_g3 - prior_mean_income_g3
  )

# Update experiment1 subset
df_exp1 <- df %>% filter(experiment1 == 1)

# ---------- ANSWER 1.7.2: Variable definitions and N ----------
"VARIABLE DEFINITIONS:"
"- recruitmentrisk: Share of clones in G4 across 3 questions (0-1 scale)"
"- prior_mean_income_g3: Expected income for G3 (before treatment)"
"- posterior_mean_income_g3: Expected income for G3 (after treatment)"
"- g3_prior_error: Deviation from true G3 mean (3M COP)"
"- g3_revision: Change in expectations (posterior - prior)"
"- info_treat: Treatment indicator (1 = received income information)"

"N for each variable (within experiment1 == 1):"
data.frame(
  Variable = c("recruitmentrisk", "prior_mean_income_g3", "posterior_mean_income_g3",
               "g3_prior_error", "g3_revision", "info_treat"),
  N = c(sum(!is.na(df_exp1$recruitmentrisk)),
        sum(!is.na(df_exp1$prior_mean_income_g3)),
        sum(!is.na(df_exp1$posterior_mean_income_g3)),
        sum(!is.na(df_exp1$g3_prior_error)),
        sum(!is.na(df_exp1$g3_revision)),
        sum(!is.na(df_exp1$info_treat)))
)

# ---------- ANSWER 1.7.5: Regression Analysis ----------
model1 <- lm(g3_revision ~ info_treat, data = df_exp1)
model2 <- lm(g3_revision ~ info_treat + g3_prior_error, data = df_exp1)
model3 <- lm(g3_revision ~ info_treat * g3_prior_error, data = df_exp1)

"MODEL 1: g3_revision ~ info_treat"
summary(model1)

"MODEL 2: g3_revision ~ info_treat + g3_prior_error"
summary(model2)

"MODEL 3: g3_revision ~ info_treat * g3_prior_error"
summary(model3)

# ---------- ANSWER 1.7.6: Heterogeneity by recruitment risk ----------
model4 <- lm(g3_revision ~ info_treat * recruitmentrisk + g3_prior_error, data = df_exp1)
model5 <- lm(g3_revision ~ info_treat * recruitmentrisk_top_lab + g3_prior_error, data = df_exp1)

"MODEL 4: Heterogeneity with continuous recruitment risk"
summary(model4)

"MODEL 5: Heterogeneity with recruitment risk categories"
summary(model5)

# ==============================================================================
# SAVE CLEANED DATASET
# ==============================================================================

write_dta(df, "output/tables/data_task_cleaned.dta")
write.csv(df, "output/tables/data_task_cleaned.csv", row.names = FALSE)

