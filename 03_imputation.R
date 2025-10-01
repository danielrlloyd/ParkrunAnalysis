### Imputes possible missing values ###

# Load Additional Packages =====================================================

library(kableExtra)
library(broom)
library(mice)

# Execute previous script ======================================================
source("01_anonymise.R")

# Imputation ===================================================================

# MICE Imputation --------------------------------------------------------------

# Run multiple imputation
parkrun_imputed <- mice
