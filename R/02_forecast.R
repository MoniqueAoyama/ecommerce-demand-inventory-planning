# Forecast weekly online units and compare models.
library(tidyverse)
library(fpp3)

weekly <- read_csv("exports/weekly_sales.csv", show_col_types = FALSE)

online <- weekly |>
  filter(channel == "online") |>
  mutate(week = yearweek(week_start)) |>
  select(week, index_group, units) |>
  as_tsibble(key = index_group, index = week)

# Hold out the last 8 weeks. The models never see them during training.
test_weeks <- 8
cutoff <- max(online$week) - test_weeks

train <- online |> filter(week <= cutoff)
test  <- online |> filter(week >  cutoff)

# Check the split
train |> as_tibble() |> summarise(first = min(week), last = max(week), weeks = n_distinct(week))
test  |> as_tibble() |> summarise(first = min(week), last = max(week), weeks = n_distinct(week))

# Plot the split on the total
online |>
  summarise(units = sum(units)) |>
  mutate(set = if_else(week <= cutoff, "train", "test")) |>
  ggplot(aes(x = week, y = units, colour = set)) +
  geom_line() +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Train and test weeks", x = NULL, y = "Units", colour = NULL)

# Fit four models on the training weeks, separately for each group
fits <- train |>
  model(
    naive  = NAIVE(units),
    snaive = SNAIVE(units ~ lag("year")),
    ets    = ETS(units ~ season("N")),   # no seasonality, ETS can't handle 52 weeks
    arima  = ARIMA(units)
  )

fits

# Forecast the 8 test weeks
fc <- fits |> forecast(h = test_weeks)

# Forecasts vs actual sales, from Jan 2020 on
fc |>
  autoplot(online |> filter(week >= yearweek("2020 W01")), level = NULL) +
  facet_wrap(~ index_group, scales = "free_y") +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Forecasts for the 8 test weeks", x = NULL, y = "Units", colour = "Model")

ggsave("reports/forecast_test.png", width = 10, height = 6)