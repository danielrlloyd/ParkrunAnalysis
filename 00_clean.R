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

# Initialize current parkrun
curr_parkrun <- ""
week <- 1

# Reads all data files together 
# and combines them into a single dataframe
for (file in data_files) {
  # Create a temporary data frame from corresponding CSV
  file_df <- read_csv(file)
  
  # Isolate parkrun location
  file_name <- basename(file)
  parkrun <- sub("_results_.*", "", file_name)
  
  # Calculate the week a parkrun occurred
  if (parkrun == curr_parkrun) {
    week = week + 1
  } else {
    curr_parkrun <- parkrun
    week <- 1
  }
  
  # Perform basic cleaning that is dependent on the file
  # Or can easily be done now
  file_df <- file_df %>%
    mutate(Parkrun = parkrun) %>%
    mutate(Week = week) %>%
    mutate(Gender = substr(Gender, 1, 1)) %>%
    mutate(`Age Grade` = as.numeric(substr(`Age Group`, 8, 12))) %>%
    mutate(`Age Group` = substr(`Age Group`, 1, 7))
  
  # Combines temporary data frame with global data frame
  parkrun_df <- bind_rows(parkrun_df, file_df)
}










