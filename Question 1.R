source("00_clean.R")
source("01_clean_time_pb_first.R")  # 运行后内存里有 parkrun_df，也写出了 parkrun_time_with_pb_first.csv

library(dplyr); library(ggplot2)

# 每个 parkrun 的完赛记录数（更接近现场“曝光量”）
counts_total <- parkrun_df %>%
  count(parkrun, name = "finish_count") %>%
  arrange(desc(finish_count))

# Top 15 柱状图
counts_total %>%
  slice_max(finish_count, n = 15) %>%
  ggplot(aes(x = reorder(parkrun, finish_count), y = finish_count)) +
  geom_col() +
  coord_flip() +
  labs(title = "Participants per parkrun (Top 15 by total finishers)",
       x = "Parkrun", y = "Count of participants")

# 最多的是：
counts_total %>% slice(1)
# 可选：导出图片
# ggsave("participants_top15_total.png", width = 10, height = 6, dpi = 300)

counts_unique <- parkrun_df %>%
  filter(tolower(trimws(parkrunner)) != "unknown") %>%
  distinct(parkrun, parkrunner) %>%
  count(parkrun, name = "unique_named_runners") %>%
  arrange(desc(unique_named_runners))

counts_unique %>%
  slice_max(unique_named_runners, n = 15) %>%
  ggplot(aes(x = reorder(parkrun, unique_named_runners), y = unique_named_runners)) +
  geom_col() +
  coord_flip() +
  labs(title = "Unique named participants per parkrun (Top 15)",
       x = "Parkrun", y = "Count of participants")

counts_unique %>% slice(1)
# ggsave("participants_top15_unique.png", width = 10, height = 6, dpi = 300)
