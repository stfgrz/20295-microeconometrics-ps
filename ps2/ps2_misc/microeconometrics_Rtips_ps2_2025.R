################################################################################
# Microeconometrics 20295 - TA 4 - Pset 2
# Instructor: Thomas Le Barbanchon | TA: Erick Baumgartner
# Partial credits to Jaime Marques Pereira, Francesca Garbin, Alexandros Cavgias

# 1. Introduction to Panel Data
# 2. Introduction to Time-Series Operators
# 3. Compact Regression Coding
# 4. High-Dimensional Fixed Effects
# 5. Motivating Parallel Trends
# 6. Estimating DiD Specifications
# 7. DiD Robustness Checks
# 8. Event Studies / TWFE
# 9. Bacon Decomposition and TWFE Weights
################################################################################

### 0. Load packages ###
# install.packages("haven")        # For reading Stata/SPSS/SAS files
# install.packages("dplyr")        # For data manipulation
# install.packages("plm")          # For panel data analysis
# install.packages("fixest")       # For fixed effects estimation
# install.packages("ggplot2")      # For data visualization
# install.packages("tidyr")        # For data tidying
# install.packages("bacondecomp")  # For Bacon decomposition
# install.packages("did")          # For difference-in-differences analysis
# install.packages("modelsummary") # For regression tables
# install.packages("twowayfeweights") # For TWFE weights analysis


library(haven)
library(dplyr)
library(plm)
library(fixest)
library(ggplot2)
library(tidyr)
library(bacondecomp)
# library(did)        # Uncomment if using Callaway & Sant’Anna's estimator
library(modelsummary) # For regression tables
library(TwoWayFEWeights) # If implementing TWFE weights

################################################################################
# 1. Introduction to Panel Data
################################################################################

df <- read_dta("http://www.stata-press.com/data/r17/nlswork.dta")
df <- df %>%
  mutate(idcode = as.numeric(idcode), year = as.numeric(year)) %>%
  arrange(idcode, year)

pdata <- pdata.frame(df, index = c("idcode", "year"))
summary(pdata)

################################################################################
# 2. Introduction to Time-Series Operators
################################################################################

df <- df %>%
  mutate(idcode = as.numeric(idcode), year = as.numeric(year)) %>%
  arrange(idcode, year)

# Here we're explicitly calling dplyr's lag/lead within grouped mutate
df <- df %>%
  group_by(idcode) %>%
  mutate(
    ln_wage_l1 = dplyr::lag(ln_wage, 1),
    ln_wage_l2 = dplyr::lag(ln_wage, 2),
    ln_wage_f1 = dplyr::lead(ln_wage, 1),
    ln_wage_f2 = dplyr::lead(ln_wage, 2)
  ) %>%
  ungroup()

summary(feols(ln_wage ~ ln_wage_l1, data = df))
summary(feols(ln_wage ~ ln_wage_l2, data = df))
summary(feols(ln_wage ~ ln_wage_l1 + ln_wage_l2, data = df))

################################################################################
# 3. Compact Regression Coding
################################################################################

summary(feols(ln_wage ~ factor(race), data = df))
summary(feols(ln_wage ~ factor(race)*factor(south), data = df))
summary(feols(ln_wage ~ factor(south)*hours, data = df))
summary(feols(ln_wage ~ factor(south) + hours + factor(south)*hours, data = df))

################################################################################
# 4. High-Dimensional Fixed Effects
################################################################################

df <- df %>%
  group_by(idcode) %>%
  arrange(year) %>%
  mutate(
    d_ln_wage = ln_wage - lag(ln_wage),
    d_wks_work = wks_work - lag(wks_work)
  ) %>%
  ungroup()

summary(lm(d_ln_wage ~ d_wks_work, data = df))
summary(feols(ln_wage ~ wks_work | idcode, data = df))
summary(feols(ln_wage ~ wks_work | idcode + year, data = df))

################################################################################
# 5. Motivating Parallel Trends
################################################################################

df <- df %>%
  mutate(
    treated = race == 2,
    Y_C = ifelse(treated == 1, wks_ue, NA),
    Y_T = ifelse(treated == 0, wks_ue, NA)
  )

df_collapsed <- df %>%
  group_by(year) %>%
  summarise(Y_C = mean(Y_C, na.rm = TRUE),
            Y_T = mean(Y_T, na.rm = TRUE))

ggplot(df_collapsed, aes(x = year)) +
  geom_line(aes(y = Y_T, color = "Control")) +
  geom_line(aes(y = Y_C, color = "Treated"), linetype = "dashed") +
  geom_vline(xintercept = 80) +
  labs(title = "Outcome Trends", y = "Number of Unemployed Weeks") +
  theme_minimal()

################################################################################
# 6. Estimating DiD Specifications
################################################################################

df_ck <- read_dta("http://fmwww.bc.edu/repec/bocode/c/CardKrueger1994.dta") %>%
  mutate(
    Y = fte,
    POST = as.numeric(t),
    TREATED = as.numeric(treated == 1),
    POST_TREAT = POST * TREATED
  )

means <- df_ck %>%
  group_by(TREATED, POST) %>%
  summarise(avg_Y = mean(Y), .groups = "drop")

DiD <- (means$avg_Y[means$TREATED==1 & means$POST==1] -
        means$avg_Y[means$TREATED==1 & means$POST==0]) -
       (means$avg_Y[means$TREATED==0 & means$POST==1] -
        means$avg_Y[means$TREATED==0 & means$POST==0])
print(DiD)

summary(lm(Y ~ POST_TREAT + POST + TREATED, data = df_ck))
summary(lm(Y ~ factor(POST)*factor(TREATED), data = df_ck))

################################################################################
# 7. DiD Robustness Checks
################################################################################

summary(lm(Y ~ POST_TREAT + POST + TREATED + POST*(bk + kfc + roys + wendys), data = df_ck))

df_nls <- read_dta("http://www.stata-press.com/data/r17/nlswork.dta") %>%
  mutate(
    year = as.numeric(year),
    Y = wks_ue,
    TREATED = race == 2,
    PLACEBO_POST = year >= 72,
    PLACEBO_POST_TREAT = PLACEBO_POST * TREATED
  )

summary(lm(Y ~ PLACEBO_POST_TREAT + PLACEBO_POST + TREATED, data = df_nls %>% filter(year < 78)))

################################################################################
# 8. Event Studies / TWFE + Sun & Abraham Estimator
################################################################################

# Example from: https://cran.r-project.org/web/packages/fixest/vignettes/fixest_walkthrough.html
data(base_stagg)
head(base_stagg)

# "Naive" TWFE DiD (note that the time to treatment for the never treated is -1000)
# (by using ref = c(-1, -1000) we exclude the period just before the treatment and 
# the never treated)
res_twfe = feols(y ~ x1 + i(time_to_treatment, ref = c(-1, -1000)) | id + year, base_stagg)

# To implement the Sun and Abraham (2020) method,
# we use the sunab(cohort, period) function
res_sa20 = feols(y ~ x1 + sunab(year_treated, year) | id + year, base_stagg)

# Plot the two TWFE results
iplot(list(res_twfe, res_sa20), sep = 0.5)

# Add the true results
att_true = tapply(base_stagg$treatment_effect_true, base_stagg$time_to_treatment, mean)[-1]
points(-9:8, att_true, pch = 15, col = 4)

legend("topleft", col = c(1, 4, 2), pch = c(20, 15, 17), 
       legend = c("TWFE", "Truth", "Sun & Abraham (2020)"))

# The full ATT
summary(res_sa20, agg = "att")

################################################################################
# 9. Bacon Decomposition and TWFE Weights
################################################################################

df <- read_dta("http://www.stata-press.com/data/r17/nlswork.dta") %>%
  mutate(year = as.numeric(year)) %>%
  group_by(idcode) %>%
  mutate(
    union_year = ifelse(union == 1, year, NA),
    first_union = min(union_year, na.rm = TRUE),
    relative_uy = year - first_union,
    never_union = is.na(first_union)
  ) %>%
  ungroup()

df <- df %>%
  group_by(idcode) %>%
  mutate(n_obs = n()) %>%
  ungroup()

max_obs <- max(df$n_obs, na.rm = TRUE)
df <- df %>% filter(n_obs == max_obs)

df <- df %>%
  mutate(entered_union = year >= first_union)

summary(feols(ln_wage ~ entered_union | idcode + year, cluster = "idcode", data = df))

bacon_model <- bacon(ln_wage ~ entered_union, data = df, id_var = "idcode", time_var = "year")
summary(bacon_model)

# Optional: TWFE weights if using that package
# twowayfeweights::twowayfeweights(ln_wage, idcode, year, entered_union, type = "feTR")

################################################################################
################################################################################
