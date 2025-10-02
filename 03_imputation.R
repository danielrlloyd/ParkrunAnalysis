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

# Model for regression
parkrun_model <- glm()

# Impute time using nearest neighbours
parkrun_imputed <- parkrun_df_cleaned %>%
  group_by(parkrun, week) %>%
  
