# Explore weekly online sales before forecasting.
library(tidyverse)
library(fpp3)

weekly <- read_csv("exports/weekly_sales.csv")

# Online only, as a time series: one row per week and group
online <- weekly |>
  filter(channel == "online") |>
  mutate(week = yearweek(week_start)) |>
  select(week, index_group, units) |>
  as_tsibble(key = index_group, index = week)

# Should be 520 rows (104 weeks x 5 groups)
nrow(online)

# Total of the five groups per week
online_total <- online |>
  summarise(units = sum(units))

# Plot 1: total online sales per week
online_total |>
  autoplot(units) +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Weekly online units", x = NULL, y = "Units")

ggsave("reports/online_weekly_total.png", width = 9, height = 4)

# Plot 2: one panel per group, each with its own scale
online |>
  autoplot(units) +
  scale_y_continuous(labels = scales::comma) +
  facet_wrap(~ index_group, scales = "free_y") +
  theme(legend.position = "none") +
  labs(title = "Weekly online units by group", x = NULL, y = "Units")

ggsave("reports/online_weekly_by_group.png", width = 10, height = 6)
