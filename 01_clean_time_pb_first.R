# ==========================================
# clean_time_pb_first.R
# Build on 00_clean.R (expects `parkrun_df` in memory)
# Adds: Time_hms, Time_seconds, Pb_time, First_timer
# Writes only: parkrun_time_with_pb_first.csv (in working directory)
# ==========================================
suppressPackageStartupMessages({
  library(dplyr); library(readr); library(stringr); library(tidyr)
})

source("00_clean.R")

# ---- Guard ----
if (!exists("parkrun_df", inherits = TRUE)) {
  stop("No `parkrun_df` found. Run source('00_clean.R') first.")
}
df <- get("parkrun_df", inherits = TRUE)

# ---- Helpers ----
extract_first_time <- function(x) {
  # First time-like token at string start: HH:MM:SS | MM:SS | seconds
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
  ifelse(is.na(x), NA_character_,
         sprintf("%d:%02d:%02d", x %/% 3600L, (x %% 3600L) %/% 60L, x %% 60L))
}
parse_time_token_to_seconds <- function(t) {
  if (is.na(t)) return(NA_integer_)
  if (str_detect(t, "^\\d{1,2}:\\d{2}:\\d{2}$")) {
    p <- as.integer(str_split(t, ":", simplify = TRUE))
    return(as.integer(p[1]*3600L + p[2]*60L + p[3]))
  }
  if (str_detect(t, "^\\d{1,2}:\\d{2}$")) {
    p <- as.integer(str_split(t, ":", simplify = TRUE))
    return(as.integer(p[1]*60L + p[2]))
  }
  if (str_detect(t, "^\\d+$")) return(as.integer(t))
  NA_integer_
}

# ---- Time cleaning (adds Time_seconds / Time_hms) ----
df <- df %>% mutate(Time_token = extract_first_time(Time))

mask_hms <- !is.na(df$Time_token) & str_detect(df$Time_token, "^\\d{1,2}:\\d{2}:\\d{2}$")
mask_ms  <- !is.na(df$Time_token) & str_detect(df$Time_token, "^\\d{1,2}:\\d{2}$")
mask_num <- !is.na(df$Time_token) & str_detect(df$Time_token, "^\\d+$")

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
if (any(mask_num)) {
  df$Time_seconds[mask_num] <- as.integer(df$Time_token[mask_num])
}
df$Time_hms <- seconds_to_hms(df$Time_seconds)

# ---- PB & First-timer rules ----
# PB priority:
#   1) explicit trailing "PB xx:yy(:zz)" in Time
#   2) if "New PB!" present, use this race time (Time_seconds)
#   3) else, group min(Time_seconds) per (parkrun, parkrunner)
pb_token        <- str_match(df$Time, "(?i)pb\\s*:?\\s*(\\d{1,2}:\\d{2}(?::\\d{2})?)")[,2]
has_new_pb      <- !is.na(df$Time) & str_detect(df$Time, "(?i)\\bnew\\s*pb!?\\b")
has_first_flag  <- !is.na(df$Time) & str_detect(df$Time, "(?i)\\bfirst\\s*timer!?\\b")

df <- df %>%
  mutate(
    Time_seconds = as.integer(Time_seconds),
    week_num     = suppressWarnings(as.integer(week))
  ) %>%
  group_by(parkrun, parkrunner) %>%
  mutate(
    min_secs_group = suppressWarnings(min(Time_seconds, na.rm = TRUE)),
    min_secs_group = ifelse(is.infinite(min_secs_group), NA_integer_, as.integer(min_secs_group))
  ) %>%
  ungroup()

pb_seconds_from_text <- vapply(pb_token, parse_time_token_to_seconds, integer(1))
pb_seconds_final <- ifelse(!is.na(pb_seconds_from_text),
                           pb_seconds_from_text,
                           ifelse(has_new_pb, df$Time_seconds, df$min_secs_group))
df$Pb_time <- seconds_to_hms(pb_seconds_final)

# First_timer:
#   base = earliest week per (parkrun, parkrunner); if all week NA, first row
#   override = if "First Timer!" or "New PB!" present, force TRUE
df <- df %>%
  group_by(parkrun, parkrunner) %>%
  mutate(
    .ft_base = if (!all(is.na(week_num))) {
      week_num == min(week_num, na.rm = TRUE)
    } else {
      dplyr::row_number() == 1
    }
  ) %>%
  ungroup() %>%
  mutate(
    First_timer = ifelse(has_first_flag | has_new_pb, TRUE, .ft_base)
  )

# ---- Remove all temporary columns & write ----
df_out <- df %>%
  select(
    -Time_token,         # temp extracted token
    -min_secs_group,     # temp group min seconds
    -.ft_base            # temp base first-timer flag
  ) %>%
  select(dplyr::everything(), Pb_time, First_timer)  # ensure new cols are present

# Keep in-memory for downstream work if needed
parkrun_df <- df_out

