### Loads all packages, and performs more simple cleaning operations ###

# Load Packages ================================================================

library(rvest)
library(tidyselect)
library(xml2)
library(tidyverse)
library(purrr)
library(readr)
library(stringr)
library(R.utils)

# Read data files ==============================================================

# List All Data Files ----------------------------------------------------------

# Get a vector of all file paths in the "data" folder
data_files <- list.files(path = "data", full.names = TRUE)

# Clean Data ===================================================================

# Create Data Frame ------------------------------------------------------------

# Create a permanent data frame to store all parkrun information
parkrun_df <- tibble()

# Combine all data files -------------------------------------------------------

# Initialize global location and week
location <- ""
week <- 1

# Reads all data files together 
# and combines them into a single dataframe
for (file in data_files) {
  # Create a temporary data frame from corresponding CSV
  file_df <- read_csv(file)
  
  # Isolate parkrun location
  file_name <- basename(file)
  parkrun <- sub("_results_.*", "", file_name)

  # Calculate parkrun week
  if (location != parkrun) {
    week <- 1
    location <- parkrun
  } else {
    week <- week + 1
  }

  # Perform basic cleaning that is dependent on the file
  file_df <- file_df %>%
    mutate(parkrun = parkrun,
           week = week,
           grade = str_remove(`Age Group`, "^[A-Z]{1,2}[MW]\\d{1,2}(-\\d{2})?"), 
           `Age Group` = str_extract(`Age Group`, "^[A-Z]{1,2}[MW]\\d{1,2}(-\\d{2})?"),
           position_by_gender = parse_number(Gender),
           Gender = substr(Gender, 1, 1)) %>%
    mutate(grade = as.numeric(substr(grade, 1, 5)))

  # Combines temporary data frame with global data frame
  parkrun_df <- bind_rows(parkrun_df, file_df)
}










