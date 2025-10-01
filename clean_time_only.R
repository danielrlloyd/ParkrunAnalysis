
suppressPackageStartupMessages({
  library(dplyr); library(readr); library(stringr); library(purrr); library(tidyr)
})


data_dir <- "D:/软件下载/R/LAB_3_GROUP_7/data"
out_path <- file.path(data_dir, "parkrun_time_clean_only.csv")


extract_first_time <- function(x) {
  ifelse(
    is.na(x), NA_character_,
    {
      s <- str_replace_all(x, "\u00A0", " ") |> str_trim()
      bad <- s == "" | s %in% c("—","-","DNF","N/A","NA","null","None")
      s[bad] <- NA_character_
      str_extract(s, "^(\\d{1,2}:\\d{2}:\\d{2}|\\d{1,2}:\\d{2}|\\d+)")
    }
  )
}


seconds_to_hms <- function(x) {
  ifelse(
    is.na(x), NA_character_,
    sprintf("%d:%02d:%02d", x %/% 3600L, (x %% 3600L) %/% 60L, x %% 60L)
  )
}


files <- list.files(data_dir, pattern = "_results_", full.names = TRUE)
stopifnot(length(files) > 0)

parse_site_event <- function(fname) {
  m <- str_match(basename(fname), "^([a-z]+)_results_(\\d+)$")
  list(Site = ifelse(any(is.na(m)), basename(fname), m[,2]),
       EventID = ifelse(any(is.na(m)), NA_integer_, as.integer(m[,3])))
}

read_one <- function(fp) {
  meta <- parse_site_event(fp)
  df <- read_csv(fp, show_col_types = FALSE, progress = FALSE)
  names(df) <- trimws(names(df))
  keep <- c("Position","parkrunner","Gender","Age Group","Club","Time")
  df <- df[, keep]
  df$Site <- meta$Site
  df$EventID <- meta$EventID
  df
}

df <- map_dfr(files, read_one)


df <- df %>%
  mutate(
    Time_token = extract_first_time(Time)
  )


mask_numeric <- !is.na(df$Time_token) & str_detect(df$Time_token, "^\\d+$")

mask_hms <- !is.na(df$Time_token) & str_detect(df$Time_token, "^\\d{1,2}:\\d{2}:\\d{2}$")

mask_ms  <- !is.na(df$Time_token) & str_detect(df$Time_token, "^\\d{1,2}:\\d{2}$")


df$Time_seconds <- NA_integer_


if (any(mask_hms)) {
  p3 <- str_split_fixed(df$Time_token[mask_hms], ":", 3)
  df$Time_seconds[mask_hms] <- as.integer(p3[,1]) * 3600L +
    as.integer(p3[,2]) * 60L +
    as.integer(p3[,3])
}


if (any(mask_ms)) {
  p2 <- str_split_fixed(df$Time_token[mask_ms], ":", 2)
  df$Time_seconds[mask_ms] <- as.integer(p2[,1]) * 60L +
    as.integer(p2[,2])
}


if (any(mask_numeric)) {
  df$Time_seconds[mask_numeric] <- as.integer(df$Time_token[mask_numeric])
}


df$Time_hms <- seconds_to_hms(df$Time_seconds)

df_out <- df %>%
  select(Position, parkrunner, Gender, `Age Group`, Club,
         Time, Time_hms, Time_seconds, Site, EventID)

write_csv(df_out, out_path)
cat("Done. Output ->", out_path, "\n")

