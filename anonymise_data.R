# Load Packages ================================================================
library(tidyverse)
library(stringr)

# Functions ====================================================================

# Isolates the first number in a string
isolate_number <- function(string) {
  
  nums = c("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
  new_string = ""
  
  for (i in length(string)) {
    if substr(string, i, i) in nums {
      new_string <- new_string + substr(string, i, i)
    }
  }
}

# Read Data ====================================================================

# Reading an arbitrary data file to test anonymising
broadpark_1 <- read_csv("data/broadpark_results_142")

# Clean Data ===================================================================

# Anonymise each runner

anon_data <- broadpark_1 %>%
  