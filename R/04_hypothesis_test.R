# Did online sales really drop from year 1 to year 2?
# Paired test: each week of year 2 against the same week of year 1.
library(tidyverse)

weekly <- read_csv("exports/weekly_sales.csv", show_col_types = FALSE)

# Total online units per week, numbered 1 to 104
online_total <- weekly |>
  filter(channel == "online") |>
  group_by(week_start) |>
  summarise(units = sum(units)) |>
  arrange(week_start) |>
  mutate(week_n = row_number())

# Week 1 pairs with week 53, week 2 with week 54, and so on
pairs <- online_total |>
  mutate(
    year         = if_else(week_n <= 52, "y1", "y2"),
    week_of_year = if_else(week_n <= 52, week_n, week_n - 52)
  ) |>
  select(week_of_year, year, units) |>
  pivot_wider(names_from = year, values_from = units) |>
  mutate(diff = y2 - y1)

# Average weekly change and how many weeks went down
pairs |>
  summarise(
    mean_y1    = round(mean(y1)),
    mean_y2    = round(mean(y2)),
    mean_diff  = round(mean(diff)),
    weeks_down = sum(diff < 0)
  )

# H0: the average weekly difference is zero (no change)
# H1: it's not zero
t.test(pairs$y2, pairs$y1, paired = TRUE)

# Same question without assuming a normal distribution
wilcox.test(pairs$y2, pairs$y1, paired = TRUE)