# Burgess et al 2015 replication with did_multiplegt_dyn

library(haven)
library(data.table)
library(fixest)
library(polars)
library(DIDmultiplegtDYN)
library(ggplot2)

root <- "/Users/sid/Desktop/Git/Chaisemartin"
out  <- file.path(root, "submission", "exercise3", "output")
dir.create(out, showWarnings = FALSE, recursive = TRUE)

d <- as.data.table(read_dta(file.path(root, "TestRA copy", "exercise3_data.dta")))
setkey(d, distnum, year)

# 1963 covariates times linear trend, per Burgess Table 1
d[, trend := year - 1963]
covars   <- c("pop1962", "area", "urbrate1962", "earnings", "wage_employment", "value_cashcrops")
demovars <- c("pop1962", "area", "urbrate1962")
for (v in covars) d[[paste0(v, "_tr")]] <- d[[v]] * d$trend
df <- as.data.frame(d)

# Static TWFE sanity checks

m_col1 <- feols(exp_dens_share ~ president | distnum + year,
                data = df, cluster = ~distnum)
allcov <- paste(paste0(covars, "_tr"), collapse = " + ")
m_col3 <- feols(as.formula(paste("exp_dens_share ~ president +", allcov,
                                  "| distnum + year")),
                data = df, cluster = ~distnum)

make_event_plot <- function(m, base_color = "#2E7D32") {
  eff <- as.data.frame(m$results$Effects,  check.names = FALSE)
  pla <- as.data.frame(m$results$Placebos, check.names = FALSE)
  eff$h <-  as.integer(sub("Effect_",  "", rownames(eff)))
  pla$h <- -as.integer(sub("Placebo_", "", rownames(pla)))
  d <- rbind(
    data.frame(h = eff$h, est = eff[, "Estimate"], lb = eff[, "LB CI"], ub = eff[, "UB CI"]),
    data.frame(h = pla$h, est = pla[, "Estimate"], lb = pla[, "LB CI"], ub = pla[, "UB CI"]),
    data.frame(h = 0,     est = 0,                  lb = NA,             ub = NA)
  )
  d <- d[order(d$h), ]

  cap_half <- 0.15  
  gap <- diff(range(c(d$lb, d$ub, d$est), na.rm = TRUE)) * 0.018 

  ggplot(d, aes(x = h, y = est)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "black", linewidth = 0.4) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "black", linewidth = 0.4) +
    geom_segment(aes(x = h, xend = h, y = lb, yend = est - gap),
                 linetype = "dashed", color = base_color,
                 linewidth = 0.5, na.rm = TRUE) +
    geom_segment(aes(x = h, xend = h, y = est + gap, yend = ub),
                 linetype = "dashed", color = base_color,
                 linewidth = 0.5, na.rm = TRUE) +
    geom_segment(aes(x = h - cap_half, xend = h + cap_half, y = lb, yend = lb),
                 linetype = "solid", color = base_color,
                 linewidth = 0.5, na.rm = TRUE) +
    geom_segment(aes(x = h - cap_half, xend = h + cap_half, y = ub, yend = ub),
                 linetype = "solid", color = base_color,
                 linewidth = 0.5, na.rm = TRUE) +
    geom_point(shape = 21, fill = "#B6D2B7", color = base_color,
               size = 3, stroke = 0.9) +
    scale_x_continuous(breaks = seq(min(d$h), max(d$h), by = 1)) +
    labs(x = "Horizon (periods since first switch)",
         y = "Dynamic effect on road expenditure share") +
    theme_bw(base_size = 11) +
    theme(
      panel.grid        = element_blank(),
      panel.border      = element_rect(color = "black", fill = NA, linewidth = 0.5),
      axis.line         = element_blank(),
      axis.ticks        = element_line(color = "black", linewidth = 0.4),
      axis.ticks.length = unit(-3, "pt"),
      axis.text.x       = element_text(color = "black", margin = margin(t = 6)),
      axis.text.y       = element_text(color = "black", margin = margin(r = 6)),
      axis.title        = element_text(color = "black"),
      legend.position   = "none",
      plot.margin       = margin(8, 12, 8, 8)
    )
}

# Part 1, dynamic effects without controls
m1 <- did_multiplegt_dyn(
  df = df, outcome = "exp_dens_share", group = "distnum", time = "year",
  treatment = "president",
  effects = 5, placebo = 3, cluster = "distnum"
)
ggsave(file.path(out, "ex3_part1_event.pdf"), make_event_plot(m1),
       width = 6.5, height = 4)

# Part 2a, demography times trend
m2a <- did_multiplegt_dyn(
  df = df, outcome = "exp_dens_share", group = "distnum", time = "year",
  treatment = "president",
  effects = 5, placebo = 3, cluster = "distnum",
  controls = paste0(demovars, "_tr")
)
ggsave(file.path(out, "ex3_part2a_event.pdf"), make_event_plot(m2a),
       width = 6.5, height = 4)

# Part 2b, all six covariates times trend
m2b <- did_multiplegt_dyn(
  df = df, outcome = "exp_dens_share", group = "distnum", time = "year",
  treatment = "president",
  effects = 5, placebo = 3, cluster = "distnum",
  controls = paste0(covars, "_tr")
)
ggsave(file.path(out, "ex3_part2b_event.pdf"), make_event_plot(m2b),
       width = 6.5, height = 4)

# Part 3, switch-out effects (Web Appendix 1.6 of dC and DH 2024)
# all 13 switching districts move in 1979 so first-switch dates are not
# staggered; Design Restriction 1 fails on both routes below

routeA <- tryCatch(
  did_multiplegt_dyn(
    df = df, outcome = "exp_dens_share", group = "distnum", time = "year",
    treatment = "president",
    effects = 5, placebo = 3, cluster = "distnum",
    switchers = "out", graph_off = TRUE
  ),
  error = function(e) conditionMessage(e)
)
writeLines(routeA)

df$not_president <- 1 - df$president
routeB <- tryCatch(
  did_multiplegt_dyn(
    df = df, outcome = "exp_dens_share", group = "distnum", time = "year",
    treatment = "not_president",
    effects = 5, placebo = 3, cluster = "distnum",
    switchers = "in", graph_off = TRUE
  ),
  error = function(e) conditionMessage(e)
)
writeLines(routeB)

# Horizon-level estimates for cross-check against the writeup tables
horizons <- rbindlist(list(
  cbind(spec = "Part 1",  as.data.table(m1$results$Effects,  keep.rownames = "term")),
  cbind(spec = "Part 2a", as.data.table(m2a$results$Effects, keep.rownames = "term")),
  cbind(spec = "Part 2b", as.data.table(m2b$results$Effects, keep.rownames = "term"))
))
fwrite(horizons, file.path(out, "ex3_horizons.csv"))
