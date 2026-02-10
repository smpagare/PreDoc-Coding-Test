# =============================================================================
# Centax Coding Test - Siddhant Pagare
# =============================================================================

# Set working directory to the folder containing the data files.
setwd('/Users/sid/Desktop/Draft/CenTax Research Economist Coding Test')

# LIBRARY LOADING ---------------------------------------------------------

library(tidyverse)
library(ggplot2)

# TASK 1 ------------------------------------------------------------------

ind_0607 <- read.csv("data/ind_0607.csv", stringsAsFactors = FALSE)
ind_0708 <- read.csv("data/ind_0708.csv", stringsAsFactors = FALSE)
hh_0708  <- read.csv("data/hh_0708.csv", stringsAsFactors = FALSE)

#Exploring the given dataset

# nrow(ind_0607)
# nrow(ind_0708)
# nrow(hh_0708)
# 
# length(unique(ind_0607$id))
# length(unique(ind_0708$id))
# length(unique(hh_0708$id))
# 
# glimpse(ind_0607)
# glimpse(ind_0708)
# glimpse(hh_0708)



# DATA CLEANING  ----------------------------------------------------

#Checking for -99 values which appear to be missing value codes in given dataset.
# We will recode -99 to NA wherever encountered.

#Missing values in variable nkids
print(table(hh_0708$nkids, useNA = "ifany"))
hh_0708 <- hh_0708 %>%
  mutate(nkids = ifelse(nkids == -99, NA, nkids))

#Missing values in variable personid
hh_0708 <- hh_0708 %>%
  mutate(across(starts_with("personid"), ~ ifelse(. == -99, NA, .)))

# Check for individuals appearing in multiple households
hh_person_map <- hh_0708 %>%
  select(hhid, personid1, personid2, personid3, personid4) %>%
  pivot_longer(cols = starts_with("personid"),
               names_to = "person_slot",
               values_to = "id") %>%
  filter(!is.na(id)) %>%
  select(hhid, id)

dup_ids <- hh_person_map$id[duplicated(hh_person_map$id)]

if (length(dup_ids) > 0) {
  # Keep the first mapping to avoid duplicating rows in the merge
  hh_person_map <- hh_person_map %>%
    distinct(id, .keep_all = TRUE)
}


# TASK 2 ------------------------------------------------------------------

#Logic
# Map individuals to households via personid1-4 in hh_0708
# Merge household-level variables onto ind_0708 using this mapping
# Merge baseline (ind_0607) individual data onto the result

# Household data without person ID columns
hh_data <- hh_0708 %>%
  select(-personid1, -personid2, -personid3, -personid4)

# Attach household ID and data to each individual
hh_ind <- hh_person_map %>%
  left_join(hh_data, by = "hhid")

# Merge individual 0708 data with household data
ind_hh_0708 <- ind_0708 %>%
  left_join(hh_ind, by = "id")

#Rows after merging ind_0708 with hh
nrow(ind_hh_0708)

#Individuals matched to a household
sum(!is.na(ind_hh_0708$hhid))

# Prepare baseline data with _bl suffix to avoid column name clashes
ind_0607_renamed <- ind_0607 %>%
  rename_with(~ paste0(.x, "_bl"), -id)

# Merge baseline individual data onto the analysis dataset
analysis <- ind_hh_0708 %>%
  left_join(ind_0607_renamed, by = "id")

#Final analysis dataset dimensions
nrow(analysis)

#Individuals with baseline data
sum(!is.na(analysis$year_bl))

# Save the cleaned/merged analysis dataset
write.csv(analysis, "output/analysis_cleaned.csv", row.names = FALSE)


# TASK 3 ------------------------------------------------------------------

##Given threshold in earned income
threshold <- 34600

# Create income bins (£1,000 width) for a binned scatter plot
analysis <- analysis %>%
  mutate(tei_bin = floor(tei / 1000) * 1000 + 500)

binned_data <- analysis %>%
  filter(!is.na(tei) & !is.na(giftaid)) %>%
  group_by(tei_bin) %>%
  summarise(
    mean_giftaid = mean(giftaid, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

# RDD-style binned scatter with separate linear fits 
p3 <- ggplot(binned_data, aes(x = tei_bin, y = mean_giftaid)) +
  geom_point(aes(size = n), alpha = 0.6) +
  geom_vline(xintercept = threshold, linetype = "dashed", color = "red",
             linewidth = 0.8) +
  geom_smooth(data = filter(binned_data, tei_bin < threshold),
              method = "lm", se = TRUE, color = "blue") +
  geom_smooth(data = filter(binned_data, tei_bin >= threshold),
              method = "lm", se = TRUE, color = "blue") +
  labs(
    title = "Gift Aid Payments vs Earned Income (2007-2008)",
    subtitle = "Binned scatter (£1,000 bins); dashed red line = £34,600 threshold",
    x = "Earned Income (£)",
    y = "Mean Gift Aid Payments (£)",
    size = "Obs per bin"
  ) +
  theme_minimal() +
  scale_x_continuous(labels = scales::comma) +
  annotate("text", x = threshold + 2000,
           y = max(binned_data$mean_giftaid, na.rm = TRUE) * 0.9,
           label = "Threshold: £34,600", color = "red", hjust = 0, size = 3.5)

print(p3)
ggsave("output/T3_giftaid_vs_income.png", p3, width = 10, height = 6, dpi = 150)

#Explanation
#The binned scatter plot shows the average Gift Aid receipts for each £1,000 increment
#in income with separate linear fit estimates used for each side of the threshold at £34,600. 
#From plot, there appears to be an upward shift in the average Gift Aid receipts
#at the threshold, suggesting a possible discontinuity.

#Specifically, the fitted line for the individual above the threshold is above the level
#predicted by the pre-cutoff trend. This is consistent with a positive effect of receiving
#the treatment, which involves crossing the income threshold.

#However, the bin averages vary substantially, especially for higher income bins because 
#of fewer observations. So, while the above graph points toward a discontinuity, 
#at the same time,it is also somewhat noisy.


# TASK 4 ------------------------------------------------------------------

#Gift Aid distribution
print(summary(analysis$giftaid))

#99th percentile
quantile(analysis$giftaid, 0.99, na.rm = TRUE)

#95th percentile
quantile(analysis$giftaid, 0.95, na.rm = TRUE)

p99 <- quantile(analysis$giftaid, 0.99, na.rm = TRUE)

analysis <- analysis %>%
  mutate(giftaid_trimmed = ifelse(giftaid > p99, NA, giftaid))

#Observations removed by trimming
sum(is.na(analysis$giftaid_trimmed)) -
  sum(is.na(analysis$giftaid))

# Recreate binned scatter with trimmed outcome
binned_trimmed <- analysis %>%
  filter(!is.na(tei) & !is.na(giftaid_trimmed)) %>%
  group_by(tei_bin) %>%
  summarise(
    mean_giftaid = mean(giftaid_trimmed, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

p4 <- ggplot(binned_trimmed, aes(x = tei_bin, y = mean_giftaid)) +
  geom_point(aes(size = n), alpha = 0.6) +
  geom_vline(xintercept = threshold, linetype = "dashed", color = "red",
             linewidth = 0.8) +
  geom_smooth(data = filter(binned_trimmed, tei_bin < threshold),
              method = "lm", se = TRUE, color = "blue") +
  geom_smooth(data = filter(binned_trimmed, tei_bin >= threshold),
              method = "lm", se = TRUE, color = "blue") +
  labs(
    title = "Gift Aid (Trimmed at 99th Percentile) vs Earned Income (2007-2008)",
    subtitle = "Binned scatter (£1,000 bins); dashed red line = £34,600 threshold",
    x = "Earned Income (£)",
    y = "Mean Gift Aid Payments (£, trimmed)",
    size = "Obs per bin"
  ) +
  theme_minimal() +
  scale_x_continuous(labels = scales::comma)

print(p4)
ggsave("output/T4_giftaid_trimmed_vs_income.png", p4, width = 10, height = 6, dpi = 150)

#Explanation
# On cutting at the 99th percentile and eliminating approximately 11 extremes,
# the binned plot looks much less noisy, making the general pattern clearer. 
# The relationship between income and Gift Aid payments is also clearer.
# 
# Importantly, the jump at the £34,600 threshold remains after the removal of these outliers;
# that is, the jump does not disappear after the removal of these observations containing
# unusually high donations.
# 
# Naturally, the trimmed specification offers clearer graphical evidence of the discontinuity
# at the cutoff. However, the initial conclusion still holds that there may be some policy effect
# around the cutoff.

# TASK 5 ------------------------------------------------------------------

# Debt instrument variables: usa through usj.
# These take values: "yes", "no", "refused", "don't know".
# We count only "yes" responses as holding that debt instrument.
# "refused" and "don't know" are treated as non-responses (not counted as debt).

debt_vars <- c("usa", "usb", "usc", "usd", "use", "usg", "ush", "usi", "usj")

# Create us_number: count of "yes" across debt instrument columns
analysis <- analysis %>%
  mutate(us_number = rowSums(across(all_of(debt_vars), ~ . == "yes"), na.rm = TRUE))

#us_number distribution (number of debt types held)
print(table(analysis$us_number, useNA = "ifany"))


# TASK 6 ------------------------------------------------------------------

# Create the treatment indicator: D = 1 if tei >= 34600 (at or above threshold)
analysis <- analysis %>%
  mutate(D = as.integer(tei >= threshold))

#Treatment group allocation
#Below threshold (D=0)
sum(analysis$D == 0)
#At/above threshold (D=1)
sum(analysis$D == 1)

# (a) Number of children
t_nkids <- t.test(nkids ~ D, data = analysis)
print(t_nkids)

# (b) House price
t_price <- t.test(price ~ D, data = analysis)
print(t_price)

# (c) Gift Aid payments in baseline year
t_giftaid_bl <- t.test(giftaid_bl ~ D, data = analysis)
print(t_giftaid_bl)

#Explanation
# None of the three covariates differ significantly between the below- and
# above-threshold groups at conventional significance levels (p > 0.05 in all
# cases)

# This suggests the two groups are broadly comparable on these observable
# characteristics.


# TASK 7 ------------------------------------------------------------------

#Explanation

# This has been identified through the balance tests carried out using Task 6.
# It is noted that there are no existing differences between those just above 
# and those just below the £34,600 limit with regards to pre-determined covariates 
# such as the number of children, house price, and baseline Gift Aid.
# Such observations are a pointer to the internal validity of this practical example
# of a regression discontinuity design. This means that those individuals just above
# and those just below the cut-off point are likely comparable.

# Moreover, a key assumption used with the RDD methodology in identifying agents within
# this framework is that agents are not able to perfectly vary the key running variable,
# in this case being earned income, in a way that would allow for strategic sorting around
# this point. In a more specific sense, these individuals, if capable of strategically
# sorting by their earned income, ought to display discontinuity in a predetermined 
# covariate around this point due to differences in systematic characteristics that
# are correlated with income and charitable giving.

# Two caveats remain. The first is that balance was tested on the full sample, 
# rather than within a narrow bandwidth around the cutoff, which would be more
# appropriate for RDD validity. The second one is that while differences are statistically
# insignificant, with small point estimate gaps indicating minor compositional variation,
# including these covariates as controls will enhance precision and protection against
# residual bias.

# Overall, the balance tests support the validity of the design, and the
# covariates could be included as controls to sharpen the estimates.

# TASK 8 ------------------------------------------------------------------

# This is a standard sharp RDD with a linear trend in the running variable
# and separate slopes allowed on each side of the cutoff.
# beta1 is the local average treatment effect (LATE) at the threshold.

# Centre the running variable at the cutoff
analysis <- analysis %>%
  mutate(tei_centered = tei - threshold)

# Estimate the model
rdd_model <- lm(giftaid ~ D + tei_centered + tei_centered:D, data = analysis)
summary(rdd_model)

#Explanation
# From estimates, it is clear that there is a statistically significant positive
# effect on charitable giving through Gift Aid of around £154 at the eligibility threshold.
# The estimates can be interpreted to represent the local average treatment effect at the
# point of discontinuity.

# Furthermore, a value of 0.128 tells us that, in terms of R-squared, we are able to
# explain roughly 13 percent of the variation in Gift Aid contributions. Now, this seems small,
# but this is perfectly in line with a lot of what we see in terms of donation behavior,
# which is generally considered to be very idiosyncratic in nature.

# TASK 9 ------------------------------------------------------------------

# Create a binary indicator for whether the household has outstanding debt.
# The variable "us" indicates if the household owes money on loans/credit.
analysis <- analysis %>%
  mutate(has_debt = as.integer(us == "yes"))

#Household debt status
print(table(analysis$has_debt, useNA = "ifany"))

rdd_debt_model <- lm(giftaid ~ D * tei_centered * has_debt, data = analysis)
summary(rdd_debt_model)

#Explanation
# This suggests that while the policy has increased Gift Aid giving at the threshold,
# the size of this effect does not vary significantly with household debt status. 
# This is because even though the point estimate for indebted households is smaller,
# which is economically plausible given tighter liquidity constraints, the standard error
# is so large that the difference is not well estimated. Thus, we cannot draw strong
# conclusions about heterogeneity in treatment effects by debt status.


# TASK 10 ------------------------------------------------------------------

analysis <- analysis %>%
  mutate(
    tei_bl_centered = tei_bl - threshold,
    D_bl = as.integer(tei_bl >= threshold)
  )

placebo_model <- lm(giftaid_bl ~ D_bl + tei_bl_centered + tei_bl_centered:D_bl,
                    data = analysis)
#Placebo Test Results (Baseline Year 2006-2007)
summary(placebo_model)

#Explanation
# The placebo test at the threshold in the pre-policy year produces a small and
# statistically insignificant coefficient of about £8.41, indicating no discontinuity
# in Gift Aid prior to the reform. This can be seen as a validation of the credibility
# of the RDD design, as it suggests that the main discontinuity observed in 2007-2008
# is not driven by pre-existing differences in giving behaviour. Instead, the £154 jump
# at the cutoff can be attributed to the policy intervention rather than underlying trends.

