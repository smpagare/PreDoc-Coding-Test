# Q5: Constructed variables - financial shares, debt, vulnerability

# Use implicate 1
df <- eff[eff$imp == 1, ]

# Financial share and debt ratio
df$fin_share  <- ifelse(df$totnet > 0, df$finet / df$totnet, NA)
df$debt_ratio <- ifelse(df$totnet > 0, df$deud / df$totnet, NA)

# Non-employment rate within household
emp_cols  <- c("emp_resp", paste0("emp_", 2:9))
self_cols <- c("self_resp", paste0("self_", 2:9))

n_employed <- rowSums(df[, emp_cols] == 1, na.rm = TRUE) +
              rowSums(df[, self_cols] == 1, na.rm = TRUE)
df$non_emp_rate <- 1 - n_employed / df$hhsize
df$non_emp_rate <- pmin(pmax(df$non_emp_rate, 0), 1)

# Ownership groups
df$owner_grp <- case_when(
  df$own == 1 & df$own_ot == 1 ~ "owner_many",
  df$own == 1 & df$own_ot == 0 ~ "owner_one",
  df$own == 0                  ~ "renter"
)
df$owner_grp <- factor(df$owner_grp, levels = c("renter", "owner_one", "owner_many"))


# Weighted quantile helper (cumulative weight approach)
wq <- function(x, w, p) {
  keep <- !is.na(x) & !is.na(w)
  x <- x[keep]; w <- w[keep]
  ord <- order(x)
  x <- x[ord]; w <- w[ord]
  cumw <- cumsum(w) / sum(w)
  x[which(cumw >= p)[1]]
}


# Q5b - Summary stats by ownership group
stats_fn <- function(data) {
  data.frame(
    mean_debt   = weighted.mean(data$debt_ratio, data$facine3, na.rm = TRUE),
    med_debt    = wq(data$debt_ratio, data$facine3, 0.5),
    p75_debt    = wq(data$debt_ratio, data$facine3, 0.75),
    mean_fin    = weighted.mean(data$fin_share, data$facine3, na.rm = TRUE),
    med_fin     = wq(data$fin_share, data$facine3, 0.5),
    p75_fin     = wq(data$fin_share, data$facine3, 0.75)
  )
}

grp_stats <- df %>%
  filter(!is.na(owner_grp), !is.na(debt_ratio)) %>%
  group_by(owner_grp) %>%
  group_modify(~ stats_fn(.x))

print(grp_stats)

write.csv(grp_stats, file.path(tab_dir, "q5b_stats_by_owner_group.csv"),
          row.names = FALSE)


# Q5c - Weighted correlation between debt_ratio and non_emp_rate
complete <- df %>% filter(!is.na(debt_ratio) & !is.na(non_emp_rate))
w <- complete$facine3

# Manual weighted correlation
wmean_d <- weighted.mean(complete$debt_ratio, w)
wmean_n <- weighted.mean(complete$non_emp_rate, w)

wcov <- sum(w * (complete$debt_ratio - wmean_d) * (complete$non_emp_rate - wmean_n)) / sum(w)
wsd_d <- sqrt(sum(w * (complete$debt_ratio - wmean_d)^2) / sum(w))
wsd_n <- sqrt(sum(w * (complete$non_emp_rate - wmean_n)^2) / sum(w))

wcor <- wcov / (wsd_d * wsd_n)

# Unweighted p-value as approximation
ct <- cor.test(complete$debt_ratio, complete$non_emp_rate)

cor_result <- data.frame(
  weighted_cor = wcor,
  unweighted_cor = ct$estimate,
  p_value = ct$p.value
)
print(cor_result)

write.csv(cor_result, file.path(tab_dir, "q5c_correlation.csv"), row.names = FALSE)


# Q5d - Vulnerability flag: high debt AND high non-employment
p75_debt <- wq(df$debt_ratio, df$facine3, 0.75)

df$vulnerable <- as.integer(df$debt_ratio > p75_debt & df$non_emp_rate > 0.5)

vuln_by_grp <- df %>%
  filter(!is.na(vulnerable)) %>%
  group_by(owner_grp) %>%
  summarise(
    vuln_rate = weighted.mean(vulnerable, facine3),
    n_vuln    = sum(vulnerable),
    n         = n()
  )

print(vuln_by_grp)

write.csv(vuln_by_grp, file.path(tab_dir, "q5d_vulnerability.csv"), row.names = FALSE)
