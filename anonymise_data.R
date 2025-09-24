# Load Packages ================================================================
library(tidyverse)
library(stringr)
library(readr)

# Functions ====================================================================

# Read Data ====================================================================

# Reading an arbitrary data file to test anonymising
broadpark_1 <- read_csv("data/broadpark_results_142")

# Clean Data ===================================================================

# Anonymise each runner

anon_data <- broadpark_1 %>%
  mutate(parkrunner_id = parse_number(parkrunner))

  