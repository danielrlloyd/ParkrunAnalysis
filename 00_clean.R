# Load Packages ================================================================

library(rvest)
library(tidyselect)
library(xml2)
library(tidyverse)
library(purrr)
library(readr)

# Read data files ==============================================================

# List All Data Files ----------------------------------------------------------

# Get a vector of all file paths in the "data" folder
data_files <- list.files(path = "data", full.names = TRUE)

# Clean Data ===================================================================

# Create Data Frame ------------------------------------------------------------

# Create a permanent data frame to store all parkrun information
parkrun_df <- tibble()

# Combine all data files -------------------------------------------------------

# Reads all data files together 
# and combines them into a single dataframe
for (file in data_files) {
  # Create a temporary data frame from corresponding CSV
  file_df <- read_csv(file)
  
  # Isolate parkrun location
  file_name <- basename(file)
  parkrun <- sub("_results_.*", "", file_name)
  
  # Isolate parkrun week
  week <- parse_number(file_name)
  
  # Perform basic cleaning that is dependent on the file
  file_df <- file_df %>%
    mutate(parkrun = parkrun) %>%
    mutate(week = week) %>%
    group_by(parkrun, week)
  
  # Combines temporary data frame with global data frame
  parkrun_df <- bind_rows(parkrun_df, file_df)
}














