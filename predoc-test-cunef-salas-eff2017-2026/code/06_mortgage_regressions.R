# Q6: Mortgage holding regressions among homeowners

# Use implicate 1, restrict to owners
df <- eff[eff$imp == 1 & eff$own == 1, ]

# Dependent variable
df$mortgage_holder <- as.integer((df$own == 1 | df$own_ot == 1) &
                                   !is.na(df$deudre) & df$deudre > 0)

# Reconstruct covariates (self-contained, not relying on earlier scripts)
df$fin_share <- ifelse(df$totnet > 0, df$finet / df$totnet, NA)

emp_cols  <- c("emp_resp", paste0("emp_", 2:9))
self_cols <- c("self_resp", paste0("self_", 2:9))
n_employed <- rowSums(df[, emp_cols] == 1, na.rm = TRUE) +
              rowSums(df[, self_cols] == 1, na.rm = TRUE)
df$non_emp_rate <- 1 - n_employed / df$hhsize
df$non_emp_rate <- pmin(pmax(df$non_emp_rate, 0), 1)

df$educ_cat <- case_when(
  df$educ_resp <= 4                            ~ "low",
  df$educ_resp <= 8                            ~ "medium",
  df$educ_resp %in% c(9, 11, 12, 1001, 1002)  ~ "high"
)
df$educ_cat <- factor(df$educ_cat, levels = c("low", "medium", "high"))

# Wealth quintiles (within owner sample)
wq_fn <- function(x, w, nq = 5) {
  ord <- order(x)
  x <- x[ord]; w <- w[ord]
  cumw <- cumsum(w) / sum(w)
  breaks <- sapply(1:(nq - 1), function(q) x[which(cumw >= q / nq)[1]])
  cuts <- c(-Inf, breaks, Inf)
  cut(x[order(ord)], breaks = cuts, labels = paste0("Q", 1:nq), include.lowest = TRUE)
}
df$wealth_q <- wq_fn(df$totnet, df$facine3)


# Models
m1 <- feols(mortgage_holder ~ non_emp_rate + fin_share + age_resp +
              I(age_resp^2) + educ_cat + hhsize,
            data = df, weights = ~facine3, vcov = "hetero")

m2 <- feols(mortgage_holder ~ non_emp_rate + fin_share + age_resp +
              I(age_resp^2) + educ_cat + hhsize + wealth_q,
            data = df, weights = ~facine3, vcov = "hetero")

m3 <- feols(mortgage_holder ~ non_emp_rate + fin_share + age_resp +
              I(age_resp^2) + educ_cat + hhsize + wealth_q +
              non_emp_rate:fin_share,
            data = df, weights = ~facine3, vcov = "hetero")

# Table
cm <- c(
  "non_emp_rate"            = "Non-employment rate",
  "fin_share"               = "Financial asset share",
  "non_emp_rate:fin_share"  = "Non-emp. x Fin. share",
  "age_resp"                = "Age",
  "I(age_resp^2)"           = "Age squared",
  "educ_catmedium"          = "Education: medium",
  "educ_cathigh"            = "Education: high",
  "hhsize"                  = "Household size",
  "wealth_qQ2"              = "Wealth Q2",
  "wealth_qQ3"              = "Wealth Q3",
  "wealth_qQ4"              = "Wealth Q4",
  "wealth_qQ5"              = "Wealth Q5"
)

gof_list <- list(
  list("raw" = "nobs",      "clean" = "N",           "fmt" = 0),
  list("raw" = "r.squared", "clean" = "R$^2$",       "fmt" = 3)
)

modelsummary(list("(1)" = m1, "(2)" = m2, "(3)" = m3),
             stars    = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
             coef_map = cm,
             gof_map  = gof_list,
             notes    = "Weighted by facine3. Heteroskedasticity-robust SEs in parentheses.")

modelsummary(list("(1)" = m1, "(2)" = m2, "(3)" = m3),
             stars    = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
             coef_map = cm,
             gof_map  = gof_list,
             notes    = "Weighted by facine3. Heteroskedasticity-robust SEs in parentheses.",
             output   = file.path(tab_dir, "q6_mortgage_regressions.tex"))
