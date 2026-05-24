# Q3: Homeownership models - LPM and probit

# Use implicate 1
df <- eff[eff$imp == 1, ]

# Education categories
df$educ_cat <- case_when(
  df$educ_resp <= 4                            ~ "low",
  df$educ_resp <= 8                            ~ "medium",
  df$educ_resp %in% c(9, 11, 12, 1001, 1002)  ~ "high"
)
df$educ_cat <- factor(df$educ_cat, levels = c("low", "medium", "high"))

df$log_hhinc <- log(pmax(df$hh_inc, 1))


# Q3a - LPM with heteroskedasticity-robust SEs
lpm_own <- feols(own ~ age_resp + I(age_resp^2) + educ_cat + emp_resp +
                   self_resp + une_resp + hhsize + log_hhinc,
                 data = df, weights = ~facine3, vcov = "hetero")
summary(lpm_own)


# Q3b - Probit
probit_own <- glm(own ~ age_resp + I(age_resp^2) + educ_cat + emp_resp +
                    self_resp + une_resp + hhsize + log_hhinc,
                  data = df, family = binomial("probit"), weights = facine3)
summary(probit_own)

# Average marginal effects
ame_own <- avg_slopes(probit_own)
ame_own_df <- as.data.frame(ame_own)
write.csv(ame_own_df, file.path(tab_dir, "q3b_ame_own.csv"), row.names = FALSE)

# Comparison table: LPM vs probit coefficients
gof_own <- list(
  list("raw" = "nobs", "clean" = "N", "fmt" = 0),
  list("raw" = "AIC",  "clean" = "AIC", "fmt" = 1)
)

modelsummary(list("LPM" = lpm_own, "Probit" = probit_own),
             stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
             gof_map = gof_own,
             output = file.path(tab_dir, "q3b_lpm_vs_probit_own.tex"))


# Q3c - Same models for other real estate (own_ot)
lpm_ot <- feols(own_ot ~ age_resp + I(age_resp^2) + educ_cat + emp_resp +
                  self_resp + une_resp + hhsize + log_hhinc,
                data = df, weights = ~facine3, vcov = "hetero")
summary(lpm_ot)

probit_ot <- glm(own_ot ~ age_resp + I(age_resp^2) + educ_cat + emp_resp +
                   self_resp + une_resp + hhsize + log_hhinc,
                 data = df, family = binomial("probit"), weights = facine3)

summary(probit_ot)

ame_ot <- avg_slopes(probit_ot)
ame_ot_df <- as.data.frame(ame_ot)
write.csv(ame_ot_df, file.path(tab_dir, "q3c_ame_own_ot.csv"), row.names = FALSE)

gof_ot <- list(
  list("raw" = "nobs", "clean" = "N", "fmt" = 0),
  list("raw" = "AIC",  "clean" = "AIC", "fmt" = 1)
)

modelsummary(list("LPM" = lpm_ot, "Probit" = probit_ot),
             stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
             gof_map = gof_ot,
             output = file.path(tab_dir, "q3c_lpm_vs_probit_own_ot.tex"))
