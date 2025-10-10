---
title: "README" 
output: html_document
---
# Parkrun Data Analysis: Puma Marketing Strategy

## Overview
This project analyzes Parkrun data from Otautahi, New Zealand to support Puma's marketing strategy. The analysis focuses on runner participation patterns, elite and consistent runners, and new runner acquisition to inform targeted marketing decisions.

## Project Structure
puma-marketing-strategy/
├── data/
│ ├── raw/ # Raw text files from Parkrun website
│ └── final_clean_data.csv.gz # Processed and cleaned dataset
├── src/
│ ├── 00_clean.R
│ ├── 01_clean_time_pb_first.R
│ ├── 02_anonymise.R
│ ├── 04_number-of-runner-and-new-runner-analysis.R
│ └── 05_elite_consistent_runner_analysis.R
├── reports/
│ ├── final-stakeholder-report.Rmd
│ ├── final-stakeholder-report.pdf
│ ├── final-technical-report.Rmd
│ └── final-technical-report.pdf
└── README.md

text


## Datasets
### Dataset 1: Raw Parkrun Data
Source: Scraped from New Zealand Parkrun website

Description: Contains 11 weeks of Parkrun data across all sites in Otautahi

Format: 74 raw text files

Size: Multiple files covering 11 weeks of parkrun events

Key Information: Runner details, finish times, event dates, locations

Update Frequency: Weekly (as new parkrun events occur)

### Dataset 2: Final Clean Dataset
Source: Processed from raw data files

Description: Cleaned and consolidated dataset with extracted important features

Format: gzipped CSV file (final_clean_data.csv.gz)

Key Features:

- Runner anonymized identifiers

- Finish times in seconds and formatted time

- Personal best (PB) records

- First timer flags

- Race completion milestones

- Volunteer milestones

- Age grade percentages

- Gender information

## Scripts
### Data Processing
**src/00_clean.R** 
Purpose: Load all required packages and perform initial data cleaning operations

Input: 74 raw text data files from Parkrun website

Output: Consolidated data frame combining all raw data

Key Operations:

- Package loading and environment setup

- Data import from multiple text files

- Basic data cleaning and standardization

- Merging of all individual event files

**src/01_clean_time_pb_first.R**
Purpose: Process and clean time-related data

Input: Time data from raw dataset

Output: Enhanced dataset with time metrics

Key Features Created:

- Finish time in seconds (numeric)

- Finish time in HH:MM:SS format

- Personal record (PB) time indicators

- First timer records and flags

**src/02_anonymise.R**
Purpose: Process runner information and ensure data privacy

Input: Parkrunner column from raw dataset

Output: Anonymized runner profiles with engagement metrics

Key Features Created:

- Runner anonymized identifiers

- Number of races completed

- Race completion milestones (e.g., 10, 50, 100 runs)

- Volunteer participation milestones

- Unique runner identification

- Analysis and Visualization
**src/04_number-of-runner-and-new-runner-analysis.R**
Purpose: Analyze participation trends and new runner acquisition

Input: Runner IDs, parkrun events, first timer records

Output: Analytical tables and visualizations

Key Outputs:

- Table of total participants per event

- Table of new runners per event

- Bar charts visualizing participation trends

- New runner acquisition patterns

**src/05_elite_consistent_runner_analysis.R**
Purpose: Identify and analyze elite and consistent runners

Input: Runner IDs, parkrun events, join dates, age grades, gender

Output: Elite runner metrics and visualizations

Key Outputs:

- Table quantifying elite and consistent runners

- Bar charts showing elite runner distribution

- Stacked bar charts by demographic factors

- Consistency patterns across events

## Reports
**reports/final-stakeholder-report.Rmd**
Purpose: Business-focused report for marketing stakeholders

Content: Marketing strategy insights, actionable recommendations

Output: PDF report with executive summary and visualizations

Key Questions Addressed:

- Runner participation patterns and trends

- New runner acquisition opportunities

- Elite runner identification and engagement strategies

- Marketing targeting recommendations

**reports/final-technical-report.Rmd**
Purpose: Technical documentation of data processing and analysis pipeline

Content: Methodological details, code explanations, data processing workflow

Output: PDF technical documentation

Key Sections:

- Data cleaning methodology

- Analysis techniques and statistical methods

- Code implementation details

- Data validation procedures


## Branching Strategy
- main branch for production-ready code

- Reporting branch for reporting development

Last updated: October 2025


## Repository
https://github.com/DATA422-DATA201-25S2/LAB_3_GROUP_7

## Trello board
https://trello.com/b/1sQj9BEy/data201-422-lab-3-group-7
