# ======================================================
# QUESTION 1 & QUESTION 2: Parkrun Participation Analysis
# ======================================================

# Load libraries
library(tidyverse)
library(lubridate)
library(scales)
library(ggthemes)
library(ggplot2)
library(dplyr)

# Read data
parkrun_data <- read.csv("clean-data.csv", stringsAsFactors = FALSE)

# Clean and prepare
clean_data <- parkrun_data %>%
  mutate(
    parkrun = as.character(parkrun),
    name_id = as.character(name_id),
    week = as.factor(week),
    week_num = suppressWarnings(as.numeric(as.character(week))),
    is_unknown = is.na(name_id) | name_id == "UNK"
  ) %>%
  filter(!is.na(parkrun), !is.na(week))

# ------------------------------------------------------
# QUESTION 1: Which Parkrun has the largest audience?
# ------------------------------------------------------

# Each distinct runner represents one potential audience member.
# Count both unique runners and total finishes for comparison.
q1_summary <- clean_data %>%
  group_by(parkrun) %>%
  summarise(
    total_finishes   = n(),
    unique_runners   = n_distinct(name_id[!is_unknown]),
    unknown_finishes = sum(is_unknown)
  ) %>%
  arrange(desc(unique_runners))

print("Q1: Unique runners and total finishes per Parkrun")
print(q1_summary)

# Bar chart – Unique runners (preferred marketing metric)
p_q1_unique <- ggplot(q1_summary,
                      aes(x = reorder(parkrun, unique_runners),
                          y = unique_runners)) +
  geom_col(fill = "#4C9F70", alpha = 0.9) +
  geom_text(aes(label = unique_runners), hjust = -0.15, size = 3) +
  coord_flip() +
  labs(title = "Unique Runners by Parkrun",
       subtitle = "Each unique identifiable runner counts once (excludes UNK)",
       x = "Parkrun", y = "Number of Unique Runners") +
  theme_minimal(base_size = 12) +
  expand_limits(y = max(q1_summary$unique_runners, na.rm = TRUE) * 1.1)

print(p_q1_unique)

# Bar chart – Total finishes (shows general activity)
p_q1_finishes <- ggplot(q1_summary,
                        aes(x = reorder(parkrun, total_finishes),
                            y = total_finishes)) +
  geom_col(fill = "#4472C4", alpha = 0.9) +
  geom_text(aes(label = total_finishes), hjust = -0.15, size = 3) +
  coord_flip() +
  labs(title = "Total Finishes by Parkrun",
       subtitle = "All appearances, including repeat visits",
       x = "Parkrun", y = "Total Finishes") +
  theme_minimal(base_size = 12) +
  expand_limits(y = max(q1_summary$total_finishes, na.rm = TRUE) * 1.1)

print(p_q1_finishes)

# Summary output
if (nrow(q1_summary) > 0) {
  top <- q1_summary %>% slice_max(unique_runners, n = 1)
  cat(sprintf("\nBest marketing opportunity: %s (%d unique runners)\n",
              top$parkrun, top$unique_runners))
}

# ------------------------------------------------------
# QUESTION 2: Do new runners join each week?
# ------------------------------------------------------

# Mark each runner’s first appearance
first_seen <- clean_data %>%
  filter(!is_unknown) %>%
  arrange(name_id, week_num) %>%
  group_by(name_id) %>%
  summarise(first_week_num = suppressWarnings(min(week_num, na.rm = TRUE)),
            .groups = "drop")

q2_df <- clean_data %>%
  left_join(first_seen, by = "name_id") %>%
  mutate(is_global_new = !is_unknown & week_num == first_week_num)

# Summarise new vs returning runners by week
q2_weekly <- q2_df %>%
  group_by(week) %>%
  summarise(
    new_runners       = sum(is_global_new, na.rm = TRUE),
    returning_runners = sum(!is_unknown & !is_global_new, na.rm = TRUE),
    total_runners     = sum(!is_unknown, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(as.numeric(as.character(week))) %>%
  mutate(percent_new = if_else(total_runners > 0,
                               100 * new_runners / total_runners, NA_real_))

print("Q2: Weekly new vs returning runners (global first definition)")
print(q2_weekly)

# Check for a 'First_timer' column (optional)
first_timer_cols <- names(q2_df)[
  stringr::str_detect(names(q2_df), regex("first", ignore_case = TRUE)) &
    stringr::str_detect(names(q2_df), regex("timer", ignore_case = TRUE))
]

if (length(first_timer_cols) > 0) {
  ft_col <- first_timer_cols[1]
  message(sprintf("Detected First-timer column: %s", ft_col))
  
  q2_weekly_ft <- q2_df %>%
    mutate(is_event_first_timer = as.logical(.data[[ft_col]])) %>%
    group_by(week) %>%
    summarise(
      first_timer_runners = sum(is_event_first_timer, na.rm = TRUE),
      total_runners = sum(!is_unknown, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(percent_first_timer = if_else(total_runners > 0,
                                         100 * first_timer_runners / total_runners, NA_real_))
  print("Q2 (event-level): Weekly first-timers based on data flag")
  print(q2_weekly_ft)
}

# Bar chart – New vs returning each week
q2_long <- q2_weekly %>%
  select(week, new_runners, returning_runners) %>%
  pivot_longer(-week, names_to = "Type", values_to = "Count") %>%
  mutate(Type = recode(Type,
                       new_runners = "New Runners (first appearance)",
                       returning_runners = "Returning Runners"))

p_q2 <- ggplot(q2_long, aes(x = week, y = Count, fill = Type)) +
  geom_col(alpha = 0.9) +
  labs(title = "New vs Returning Runners by Week",
       subtitle = "Global first-time definition; excludes UNK",
       x = "Week", y = "Runner Count", fill = NULL) +
  theme_minimal(base_size = 12)

print(p_q2)

