# Safety stock and reorder point from the forecast error in the test weeks.
library(tidyverse)

test_fc <- read_csv("exports/test_forecasts.csv", show_col_types = FALSE)
next_fc <- read_csv("exports/forecast_next_8_weeks.csv", show_col_types = FALSE)

# Assumed for this project, since the dataset has no inventory data
lead_time_weeks <- 2      # weeks between placing an order and receiving it
service_level   <- 0.95   # chance of not running out during the lead time
z <- qnorm(service_level) # about 1.64

# Model chosen for each group in the forecast step
chosen <- next_fc |> distinct(index_group, model)

# How much the chosen model missed, week by week, in the test
error_sd <- test_fc |>
  inner_join(chosen, by = c("index_group", ".model" = "model")) |>
  group_by(index_group) |>
  summarise(error_sd = sd(units - forecast))

# Safety stock covers the forecast error over the lead time.
# Reorder point = expected demand during the lead time + safety stock.
inventory <- next_fc |>
  arrange(index_group, week_start) |>
  group_by(index_group, model) |>
  summarise(lead_time_demand = sum(head(forecast, lead_time_weeks)), .groups = "drop") |>
  left_join(error_sd, by = "index_group") |>
  mutate(
    error_sd      = round(error_sd),
    safety_stock  = round(z * error_sd * sqrt(lead_time_weeks)),
    reorder_point = lead_time_demand + safety_stock,
    ss_pct        = round(100 * safety_stock / lead_time_demand, 1)
  )

inventory

write_csv(inventory, "exports/inventory_policy.csv")