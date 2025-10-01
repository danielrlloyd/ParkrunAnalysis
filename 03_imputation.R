### Imputes possible missing values ###

# Load Additional Packages =====================================================

library(kableExtra)
library(broom)
library(mice)
library(lubridate)
library(hms)

# Execute previous script ======================================================
source("01_anonymise.R")


# Imputation ===================================================================

# Regression Imputation -------------------------------------------------

# Temporarily isolate time for imputation
parkrun_df_time <- parkrun_df_cleaned %>%
  filter(!is.na(Time)) %>%
  mutate(
    Time_clean <- str_extract(Time, "\\d{1,2}:\\d{2}(?::\\d{2})?"),
    Time_parsed = case_when(
      str_count(Time_clean, ":") == 2 ~ hms(Time_clean),
      str_count(Time_clean, ":") == 1 ~ ms(Time_clean),
      TRUE ~ NA
    ),
    Time_seconds <- as.numeric(Time_parsed)
  )

# Model for regression
parkrun_model <- glm()

# Impute time using nearest neighbours
parkrun_imputed <- parkrun_df_cleaned %>%
  group_by(parkrun, week) %>%
  
