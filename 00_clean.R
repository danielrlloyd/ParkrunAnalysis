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
data_files <- list.files(path = "data", pattern = "\\.csv$", full.names = TRUE)

# Create Data Frame ------------------------------------------------------------

# Create a permanent data frame to store all parkrun information
parkrun_df <- tibble()

# Combine all data files -------------------------------------------------------

# Reads all data files together 
# and combines them into a single dataframe
for (file in data_files) {
  file_df <- read_csv(file)
  
  parkrun_df <- bind_rows(parkrun_df, file_df)
}














