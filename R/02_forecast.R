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
    snaive = SNAIVE(units ~ lag(52)),   # same week last year
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

# Put each forecast next to what actually sold in that week
compare <- fc |>
  as_tibble() |>
  select(index_group, .model, week, forecast = .mean) |>
  left_join(as_tibble(test), by = c("index_group", "week"))

# Error by group and model
errors <- compare |>
  group_by(index_group, .model) |>
  summarise(
    mae      = mean(abs(units - forecast)),
    # total error as a % of total sales, so groups of any size compare
    wape_pct = 100 * sum(abs(units - forecast)) / sum(units),
    # positive = forecast too high, negative = too low
    bias_pct = 100 * sum(forecast - units) / sum(units),
    .groups  = "drop"
  ) |>
  mutate(across(c(mae, wape_pct, bias_pct), \(x) round(x, 1))) |>
  arrange(index_group, wape_pct)

errors |> print(n = 20)

# Best model for each group = lowest WAPE
best <- errors |>
  group_by(index_group) |>
  slice_min(wape_pct, n = 1) |>
  ungroup()

best

# Same error for all groups together, to compare the models overall
compare |>
  group_by(.model) |>
  summarise(
    wape_pct = round(100 * sum(abs(units - forecast)) / sum(units), 1),
    bias_pct = round(100 * sum(forecast - units) / sum(units), 1)
  ) |>
  arrange(wape_pct)

# Save for the Tableau dashboard
write_csv(errors, "exports/forecast_errors.csv")

# Weekly test forecasts and actual sales, used for safety stock
write_csv(compare, "exports/test_forecasts.csv")

# Final forecast: refit on all 104 weeks and forecast the next 8.
# Models picked from the test error: seasonal naive for Ladieswear,
# naive for the other groups (Baby/Children tied with ETS, naive is simpler).
final_fits <- online |>
  model(
    naive  = NAIVE(units),
    snaive = SNAIVE(units ~ lag(52))
  )

final_fc <- final_fits |>
  forecast(h = test_weeks) |>
  filter((index_group == "Ladieswear" & .model == "snaive") |
           (index_group != "Ladieswear" & .model == "naive"))

# Table with the point forecast only. The model ranges went below zero
# and grew too fast to be useful, so safety stock uses the test error instead.
forecast_table <- final_fc |>
  as_tibble() |>
  transmute(
    index_group,
    model      = .model,
    week_start = as.Date(week),
    forecast   = round(.mean)
  )

forecast_table |> print(n = 40)

write_csv(forecast_table, "exports/forecast_next_8_weeks.csv")

# Chart: 2020 sales and the next 8 weeks
final_fc |>
  autoplot(online |> filter(week >= yearweek("2020 W01")), level = NULL) +
  facet_wrap(~ index_group, scales = "free_y") +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Forecast for the next 8 weeks", x = NULL, y = "Units")

ggsave("reports/forecast_next_8_weeks.png", width = 10, height = 6)