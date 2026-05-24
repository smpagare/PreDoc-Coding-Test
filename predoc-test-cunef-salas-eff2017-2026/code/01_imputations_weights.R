# Q1: Multiple imputations and survey weights
# EFF 2017 - 5 implicates, weight = facine3


# -- Data checks --

dim(eff)
table(eff$imp)

# Any missing values in the key variables?
colSums(is.na(eff[, c("totnet", "facine3", "imp")]))

summary(eff$facine3)
summary(eff$totnet)


# Q1a - Adjusted weight for pooled estimation
# facine3 is replicated across 5 implicates, so divide by 5
eff$w_adj <- eff$facine3 / 5

pooled_mean <- weighted.mean(eff$totnet, eff$w_adj)


# Q1b - Why we adjust: population totals, not means
pop_original <- sum(eff$facine3)
pop_adjusted <- sum(eff$w_adj)
wealth_original <- sum(eff$totnet * eff$facine3)
wealth_adjusted <- sum(eff$totnet * eff$w_adj)

# The mean is the same either way -- the ratio of sums cancels the 5x
mean_original <- weighted.mean(eff$totnet, eff$facine3)
mean_adjusted <- weighted.mean(eff$totnet, eff$w_adj)

q1b <- data.frame(
  weight      = c("facine3 (original)", "facine3/5 (adjusted)"),
  sum_weights = c(pop_original, pop_adjusted),
  total_wealth = c(wealth_original, wealth_adjusted),
  mean_wealth  = c(mean_original, mean_adjusted)
)

write.csv(q1b, file.path(tab_dir, "q1b_weight_comparison.csv"), row.names = FALSE)


# Q1c - Weighted mean by implicate (using original weights)
imp_means <- numeric(5)
for (m in 1:5) {
  sub <- eff[eff$imp == m, ]
  imp_means[m] <- weighted.mean(sub$totnet, sub$facine3)
}


# Q1d - Rubin's combining rules
Q_bar <- mean(imp_means)

# Between-imputation variance
B <- var(imp_means)

# Within-imputation variance: weighted variance / effective n, averaged across implicates
W_vec <- numeric(5)
for (m in 1:5) {
  sub <- eff[eff$imp == m, ]
  w   <- sub$facine3
  mu  <- weighted.mean(sub$totnet, w)

  # Weighted variance (reliability weights)
  wvar <- sum(w * (sub$totnet - mu)^2) / sum(w)

  # Kish effective sample size
  n_eff <- sum(w)^2 / sum(w^2)

  W_vec[m] <- wvar / n_eff
}
W <- mean(W_vec)

# Total variance and SE
T_var <- W + (1 + 1/5) * B
se    <- sqrt(T_var)

q1d <- data.frame(
  Q_bar = Q_bar,
  B     = B,
  W     = W,
  T_var = T_var,
  SE    = se
)

write.csv(q1d, file.path(tab_dir, "q1d_rubins_rules.csv"), row.names = FALSE)
