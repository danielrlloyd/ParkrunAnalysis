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



# Clean the parkrunner column in parkrun_df dataframe
# ------------------------------------------------------------------------------

library(stringr)

# Clean the 'parkrunner' column in 'parkrun_df'
parkrun_df_cleaned <- parkrun_df %>%
  mutate(
    # 1. Extract runner name (everything before the first digit)
    name = str_extract(parkrunner, "^[A-Za-z\\s\\.\\-]+(?=\\d)") %>% str_trim(),

    # 2. Extract number of parkruns completed
    parkruns_completed = str_extract(parkrunner, "(?<=[A-Za-z\\s])\\d+(?=\\s*parkruns)") %>%
      as.numeric(),

    # 3. Extract race completion milestone
    race_milestone = case_when(
      str_detect(parkrunner, "Member of the 250 Club") ~ "250 Club",
      str_detect(parkrunner, "Member of the 100 Club") ~ "100 Club",
      str_detect(parkrunner, "Member of the 50 Club") ~ "50 Club",
      str_detect(parkrunner, "Member of the 25 Club") ~ "25 Club",
      str_detect(parkrunner, "Member of the 10 Club") ~ "10 Club",
      TRUE ~ "No Milestone"  
    ),

    # 4. Extract volunteer milestone
    volunteer_milestone = case_when(
      str_detect(parkrunner, "Member of the Volunteer 100 Club") ~ "Volunteer 100 Club",
      str_detect(parkrunner, "Member of the Volunteer 50 Club") ~ "Volunteer 50 Club",
      str_detect(parkrunner, "Member of the Volunteer 25 Club") ~ "Volunteer 25 Club",
      str_detect(parkrunner, "Member of the Volunteer 10 Club") ~ "Volunteer 10 Club",
      TRUE ~ "No Volunteer Milestone"  
    ),

    # Handle "Unknown" runners
    name = ifelse(parkrunner == "Unknown", "Unknown", name),
    parkruns_completed = ifelse(parkrunner == "Unknown", NA_real_, parkruns_completed),
    race_milestone = ifelse(parkrunner == "Unknown", NA_character_, race_milestone),
    volunteer_milestone = ifelse(parkrunner == "Unknown", NA_character_, volunteer_milestone)
    ,
    
    # 5. Anonymize names
    ## Turn names into Alphabetical name_id (using Ceasar cipher)
    name_id = ifelse(name != "Unknown" & !is.na(name),
                map_chr(name, ~ {
                  # Convert to uppercase and remove spaces for consistent encoding
                  clean_name <- toupper(str_replace_all(.x, "[^A-Z]", ""))
                  
                  # Shift each letter by a fixed amount (3 positions: A->D, B->E, ..., Z->C)
                  encoded_chars <- map_chr(str_split(clean_name, "")[[1]], function(char) {
                    if (char %in% LETTERS) {
                      new_char_code <- (utf8ToInt(char) - 65 + 3) %% 26 + 65
                      intToUtf8(new_char_code)
                    } else {
                      char
                    }
                  })
                  paste0(paste(encoded_chars, collapse = ""))
                }),
                paste0("UNK")),  # For Unknown runners
    
    # Alternative: Numeric name_id based on name hash
    name_id_numeric = ifelse(name != "Unknown" & !is.na(name),
                        as.integer(digest::digest2int(name)),
                        NA_integer_)
    )

# remove column 'parkrunner' and 'name'
parkrun_df_cleaned <- parkrun_df_cleaned %>% select(-parkrunner, -name)



# rearranging column order, this need to update when the data is totally cleaned
parkrun_df_cleaned %>% select(`name`, everything())


#export csv file
write.csv(parkrun_df_cleaned,"clean-data.csv", row.names = FALSE)
print ('CSV created Successfully :)')








