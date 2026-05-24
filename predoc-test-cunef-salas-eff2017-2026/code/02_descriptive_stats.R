# Q2: Descriptive statistics - homeownership by age and gender

library(boot)

# Work with implicate 1 for descriptive plots
df <- eff[eff$imp == 1, ]

# Age bins (25-80, 5-year groups)
df <- df[df$age_resp >= 25 & df$age_resp < 85, ]
df$age_grp <- cut(df$age_resp,
                  breaks = seq(25, 85, 5),
                  right = FALSE,
                  labels = paste0(seq(25, 80, 5), "-", seq(29, 84, 5)))


# Q2a - Weighted homeownership rate by age group
own_by_age <- df |> 
  group_by(age_grp) |>
  summarise(
    own_rate = weighted.mean(own, facine3),
    n = n()
  )


# Q2b - Homeownership by age and gender (3 series)
own_all <- df |>
  group_by(age_grp) |>
  summarise(own_rate = weighted.mean(own, facine3), group = "All")

own_men <- df |>
  filter(gender_resp == 0) |>
  group_by(age_grp) |>
  summarise(own_rate = weighted.mean(own, facine3), group = "Men")

own_women <- df |>
  filter(gender_resp == 1) |>
  group_by(age_grp) |>
  summarise(own_rate = weighted.mean(own, facine3), group = "Women")

own_gender <- bind_rows(own_all, own_men, own_women)

p_own <- ggplot(own_gender, aes(x = age_grp, y = own_rate,
                                color = group, group = group)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.8) +
  scale_color_manual(values = c("All" = "black", "Men" = "blue", "Women" = "red")) +
  scale_y_continuous(labels = scales::percent_format()) +
  theme_bw(base_size = 11) +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  labs(x = "Age group", y = "Homeownership rate", color = NULL)

ggsave(file.path(fig_dir, "q2b_homeownership_age_gender.pdf"),
       p_own, width = 7, height = 4.5)


# Q2c - Bootstrapped weighted median of net wealth by age group
weighted_median <- function(x, w) {
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  cumw <- cumsum(w) / sum(w)
  x[which(cumw >= 0.5)[1]]
}

set.seed(42)

boot_median <- function(data, idx) {
  d <- data[idx, ]
  weighted_median(d$totnet, d$facine3)
}

# Bootstrap by age group
age_levels <- levels(df$age_grp)
boot_results <- data.frame()

for (ag in age_levels) {
  sub <- df[df$age_grp == ag, ]
  b <- boot(sub, boot_median, R = 500)
  ci <- boot.ci(b, type = "perc")

  boot_results <- rbind(boot_results, data.frame(
    age_grp = ag,
    median  = b$t0,
    ci_lo   = ci$percent[4],
    ci_hi   = ci$percent[5]
  ))
}

p_median <- ggplot(boot_results, aes(x = age_grp, y = median, group = 1)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "steelblue") +
  geom_line(color = "steelblue", linewidth = 0.7) +
  geom_point(color = "steelblue", size = 1.8) +
  scale_y_continuous(labels = scales::comma) +
  theme_bw(base_size = 11) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(x = "Age group", y = "Median net wealth (EUR)",
       caption = "95% bootstrap CI (R = 500, percentile method)")

ggsave(file.path(fig_dir, "q2c_median_wealth_bootstrap.pdf"),
       p_median, width = 7, height = 4.5)


# Q2d - Reusable plotting function
plot_ownership_rate <- function(data, outcome_var, xlab, ylab, title) {

  rates_all <- data |>
    group_by(age_grp) |>
    summarise(rate = weighted.mean(.data[[outcome_var]], facine3), group = "All")

  rates_men <- data |>
    filter(gender_resp == 0) |>
    group_by(age_grp) |>
    summarise(rate = weighted.mean(.data[[outcome_var]], facine3), group = "Men")

  rates_women <- data |>
    filter(gender_resp == 1) |>
    group_by(age_grp) |>
    summarise(rate = weighted.mean(.data[[outcome_var]], facine3), group = "Women")

  rates <- bind_rows(rates_all, rates_men, rates_women)

  ggplot(rates, aes(x = age_grp, y = rate, color = group, group = group)) +
    geom_line(linewidth = 0.7) +
    geom_point(size = 1.8) +
    scale_color_manual(values = c("All" = "black", "Men" = "blue", "Women" = "red")) +
    scale_y_continuous(labels = scales::percent_format()) +
    theme_bw(base_size = 11) +
    theme(
      legend.position = "bottom",
      axis.text.x = element_text(angle = 45, hjust = 1)
    ) +
    labs(x = xlab, y = ylab, title = title, color = NULL)
}

# Demonstrate on other real estate ownership
p_own_ot <- plot_ownership_rate(df, "own_ot",
                                xlab = "Age group",
                                ylab = "Ownership rate",
                                title = "Other real estate ownership by age and gender")

ggsave(file.path(fig_dir, "q2d_other_realestate_ownership.pdf"),
       p_own_ot, width = 7, height = 4.5)
