# Load required libraries
library(tidyverse)
library(lubridate)
library(scales)
library(ggthemes)
library(ggplot2)
library(dplyr)

# Read the data
parkrun_data <- read.csv("clean-data.csv")

# Clean and prepare the data - using grade for elite classification
clean_data <- parkrun_data %>%
  filter(!is.na(Time_seconds) & Time_seconds > 0 & !is.na(grade)) %>%
  mutate(
    Time_minutes = Time_seconds / 60,
    elite_runner = grade >= 70,  
    week = as.factor(week),
    Gender = factor(Gender, levels = c("M", "F"))  # Ensure consistent gender coding
  )

# QUESTION 4: TARGETING ELITE RUNNERS USING GRADE

# Analyze elite runners by location and gender
elite_analysis_gender <- clean_data %>%
  group_by(parkrun, Gender) %>%
  summarise(
    total_runners = n(),
    elite_runners = sum(elite_runner),
    elite_percentage = elite_runners / total_runners * 100,
    avg_grade = mean(grade, na.rm = TRUE),
    max_grade = max(grade, na.rm = TRUE)
  ) %>%
  arrange(desc(elite_runners))

# Overall elite analysis by location
elite_analysis_overall <- clean_data %>%
  group_by(parkrun) %>%
  summarise(
    total_runners = n(),
    elite_runners = sum(elite_runner),
    elite_percentage = elite_runners / total_runners * 100,
    avg_grade = mean(grade, na.rm = TRUE)
  ) %>%
  arrange(desc(elite_runners))

print("Elite Runners Analysis by Location and Gender (Grade >= 70):")
print(elite_analysis_gender)

# Visualize elite runners distribution by gender

# Bar chart: Number of elite runners by location and gender
p1 <- ggplot(elite_analysis_gender, aes(x = reorder(parkrun, -elite_runners), y = elite_runners, fill = Gender)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.8) +
  geom_text(aes(label = elite_runners), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5, size = 3) +
  scale_fill_manual(values = c("M" = "steelblue", "F" = "pink"),
                    labels = c("M" = "Male", "F" = "Female")) +
  labs(title = "Number of Elite Runners by Location and Gender",
       subtitle = "Elite runners defined as Grade >= 70%",
       x = "Location", 
       y = "Number of Elite Runners",
       fill = "Gender") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top")

print(p1)

# Bar chart: Percentage of elite runners by location and gender
p2 <- ggplot(elite_analysis_gender, aes(x = reorder(parkrun, -elite_percentage), y = elite_percentage, fill = Gender)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.8) +
  geom_text(aes(label = paste0(round(elite_percentage, 1), "%")), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5, size = 3) +
  scale_fill_manual(values = c("M" = "steelblue", "F" = "pink"),
                    labels = c("M" = "Male", "F" = "Female")) +
  labs(title = "Percentage of Elite Runners by Location and Gender",
       subtitle = "Elite runners defined as Grade >= 70%",
       x = "Location", 
       y = "Percentage of Elite Runners (%)",
       fill = "Gender") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top")

print(p2)

# Additional visualization: Stacked bar chart showing gender composition
p3 <- ggplot(elite_analysis_gender, aes(x = reorder(parkrun, -elite_runners), y = elite_runners, fill = Gender)) +
  geom_bar(stat = "identity", position = "stack") +
  geom_text(aes(label = elite_runners), 
            position = position_stack(vjust = 0.5), 
            size = 3, color = "white") +
  scale_fill_manual(values = c("M" = "steelblue", "F" = "pink"),
                    labels = c("M" = "Male", "F" = "Female")) +
  labs(title = "Gender Composition of Elite Runners by Location",
       subtitle = "Elite runners defined as Grade >= 70%",
       x = "Location", 
       y = "Number of Elite Runners",
       fill = "Gender") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(p3)

# High-performance analysis (Grade >= 80)
high_perf_analysis <- clean_data %>%
  filter(grade >= 80) %>%
  group_by(parkrun, Gender) %>%
  summarise(
    high_perf_runners = n(),
    avg_high_perf_grade = mean(grade, na.rm = TRUE)
  ) %>%
  arrange(desc(high_perf_runners))

print("High Performance Runners Analysis (Grade >= 80):")
print(high_perf_analysis)

# Visualization for high performance runners
p4 <- ggplot(high_perf_analysis, aes(x = reorder(parkrun, -high_perf_runners), y = high_perf_runners, fill = Gender)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.8) +
  geom_text(aes(label = high_perf_runners), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5, size = 3) +
  scale_fill_manual(values = c("M" = "darkblue", "F" = "hotpink"),
                    labels = c("M" = "Male", "F" = "Female")) +
  labs(title = "World-Class Runners by Location and Gender",
       subtitle = "Runners with Grade >= 80%",
       x = "Location", 
       y = "Number of World-Class Runners",
       fill = "Gender") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top")

print(p4)


# Gender ratios by location
gender_ratios <- elite_analysis_gender %>%
  group_by(parkrun) %>%
  summarise(
    male_elite = sum(elite_runners[Gender == "M"]),
    female_elite = sum(elite_runners[Gender == "F"]),
    total_elite = sum(elite_runners),
    female_ratio = female_elite / total_elite * 100
  ) %>%
  arrange(desc(total_elite))

print("Gender Ratios of Elite Runners by Location:")
print(gender_ratios)


# QUESTION 4: CONSISTENT RUNNERS ANALYSIS

# Identify consistent runners (appearing in multiple weeks)
runner_consistency <- clean_data %>%
  group_by(name_id, parkrun) %>%
  summarise(
    weeks_participated = n_distinct(week),
    total_runs = n(),
    avg_time = mean(Time_minutes),
    first_week = min(as.numeric(as.character(week))),
    last_week = max(as.numeric(as.character(week)))
  ) %>%
  mutate(
    consistency_level = case_when(
      weeks_participated >= 5 ~ "Highly Consistent (5+ weeks)",
      weeks_participated >= 3 ~ "Moderately Consistent (3-4 weeks)",
      TRUE ~ "Occasional (1-2 weeks)"
    )
  )

glimpse(runner_consistency)


# Consistency summary by location
consistency_by_location <- runner_consistency %>%
  group_by(parkrun) %>%
  summarise(
    total_unique_runners = n(),
    highly_consistent = sum(weeks_participated >= 5),
    moderately_consistent = sum(weeks_participated >= 3 & weeks_participated <= 4),
    occasional = sum(weeks_participated <= 2),
    pct_highly_consistent = highly_consistent / total_unique_runners * 100,
    avg_weeks_per_runner = mean(weeks_participated)
  ) %>%
  arrange(desc(avg_weeks_per_runner))

print("Runner Consistency by Location:")
print(consistency_by_location)

# Overall consistency distribution
overall_consistency <- runner_consistency %>%
  count(consistency_level) %>%
  mutate(percentage = n / sum(n) * 100)

print("Overall Consistency Distribution:")
print(overall_consistency)

# Visualize consistency patterns

# Consistency distribution by location
p3 <- ggplot(consistency_by_location, aes(x = reorder(parkrun, -avg_weeks_per_runner), y = avg_weeks_per_runner)) +
  geom_bar(stat = "identity", fill = "darkgreen", alpha = 0.8) +
  geom_text(aes(label = round(avg_weeks_per_runner, 1)), vjust = -0.5, size = 3) +
  labs(title = "Average Weeks Participation by Location",
       subtitle = "Higher values indicate more consistent runner base",
       x = "Location", y = "Average Weeks per Runner") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(p3)

# Consistency level breakdown
p4 <- runner_consistency %>%
  count(parkrun, consistency_level) %>%
  group_by(parkrun) %>%
  mutate(percentage = n / sum(n) * 100) %>%
  ggplot(aes(x = parkrun, y = percentage, fill = consistency_level)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = c("Highly Consistent (5+ weeks)" = "#2E8B57", 
                               "Moderately Consistent (3-4 weeks)" = "#FFA500", 
                               "Occasional (1-2 weeks)" = "#CD5C5C")) +
  labs(title = "Runner Consistency Distribution by Location",
       subtitle = "Breakdown of runner participation patterns",
       x = "Location", y = "Percentage (%)", fill = "Consistency Level") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom")

print(p4)

# Time series of participation by location
weekly_participation <- clean_data %>%
  group_by(parkrun, week) %>%
  summarise(weekly_runners = n_distinct(name_id)) %>%
  mutate(week_num = as.numeric(as.character(week)))

p5 <- ggplot(weekly_participation, aes(x = week_num, y = weekly_runners, color = parkrun)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(title = "Weekly Participation Trends by Location",
       subtitle = "Tracking runner attendance over time",
       x = "Week", y = "Number of Runners", color = "Location") +
  theme_minimal() +
  scale_x_continuous(breaks = 1:max(weekly_participation$week_num))

print(p5)

