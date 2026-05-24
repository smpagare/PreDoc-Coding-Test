# Q4: Merge language proxy, construct international exposure variable

# Use implicate 1
df <- eff[eff$imp == 1, ]

# Q4a - Merge second language probabilities
df <- df %>%
  left_join(lang, by = "educ_resp")

# Unmatched education codes
unmatched <- unique(df$educ_resp[is.na(df$p_knows_second_lang)])
unmatched  # 5 and 7 - no row in lang file

# Impute with weighted mean of matched observations
wmean_lang <- weighted.mean(df$p_knows_second_lang[!is.na(df$p_knows_second_lang)],
                            df$facine3[!is.na(df$p_knows_second_lang)])
df$p_knows_second_lang[is.na(df$p_knows_second_lang)] <- wmean_lang


# Q4b - International exposure proxy
# Probability of knowing a second language x high education indicator
df$high_educ <- as.integer(df$educ_resp %in% c(9, 11, 12, 1001, 1002))
df$intl_proxy <- df$p_knows_second_lang * df$high_educ

# Wealth quintiles via cumulative weights
wp_fn <- function(x, w, nq = 5) {
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  cumw <- cumsum(w) / sum(w)
  breaks <- sapply(1:(nq - 1), function(q) x[which(cumw >= q / nq)[1]])
  cuts <- c(-Inf, breaks, Inf)
  cut(x[order(ord)], breaks = cuts, labels = paste0("Q", 1:nq), include.lowest = TRUE)
}

df$wealth_q <- wp_fn(df$totnet, df$facine3)

# Bar chart: mean proxy by wealth quintile
proxy_by_wq <- df %>%
  group_by(wealth_q) %>%
  summarise(mean_proxy = weighted.mean(intl_proxy, facine3))

p_proxy <- ggplot(proxy_by_wq, aes(x = wealth_q, y = mean_proxy)) +
  geom_col(fill = "steelblue", width = 0.6) +
  theme_bw(base_size = 11) +
  labs(x = "Wealth quintile", y = "Mean international proxy")

print(p_proxy)

ggsave(file.path(fig_dir, "q4b_proxy_by_wealth.pdf"),
       p_proxy, width = 7, height = 4.5)


# Q4c - LPM: business ownership on international proxy
lpm_neg <- feols(neg ~ intl_proxy + age_resp + I(age_resp^2) + emp_resp +
                   self_resp + une_resp + hhsize,
                 data = df, weights = ~facine3, vcov = "hetero")

summary(lpm_neg)

# In a linear model the coefficient on intl_proxy IS the AME
# Context: mean predicted probability by wealth quintile
df$yhat_neg <- predict(lpm_neg)

pred_by_wq <- df %>%
  group_by(wealth_q) %>%
  summarise(mean_pred = weighted.mean(yhat_neg, facine3))

write.csv(pred_by_wq, file.path(tab_dir, "q4c_predicted_neg_by_wealth.csv"),
          row.names = FALSE)
