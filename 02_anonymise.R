### Anonymises the names of every parkrunner ###

# Load Cleaning Script =========================================================

# Execute 00_clean.R
source("01_clean_time_pb_first.R")

# Anonymisation ================================================================

# Clean the parkrunner column in parkrun_df dataframe
# ------------------------------------------------------------------------------

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

# remove column 'parkrunner' and 'name' and 'week_num'

parkrun_df_cleaned <- parkrun_df_cleaned %>% 
  select(-parkrunner, 
         -name, 
         -week_num, 
         -race_milestone, 
         -volunteer_milestone,
         -name_id_numeric,
         -parkruns_completed,
         -Time)



# rearranging column order, this need to update when the data is totally cleaned
parkrun_df_cleaned <- parkrun_df_cleaned %>% 
  select(name_id, everything())


#export csv file, and gzip it
write.csv(parkrun_df_cleaned,"clean-data.csv", row.names = FALSE)

gzip("clean-data.csv")
print ('CSV created Successfully :)')

