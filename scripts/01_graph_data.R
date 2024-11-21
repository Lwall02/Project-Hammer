price_change_data <- read_csv("data/egg_price_change_data.csv")

# Bar Plot of Price Changes by Vendor
price_change_data |>
  mutate(price_change = round(price_change, 2)) |>
  ggplot(aes(x = vendor, y = price_change, fill = vendor)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Price Change of Egg Dozens by Vendor", 
       x = "Vendor", 
       y = "Price Change in CAD") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Vendor-wise Price Change Distribution (Facet Grid)
price_change_data |>
  mutate(price_change = round(price_change, 2)) |>
  ggplot(aes(x = price_change)) +
  geom_histogram(bins = 20, fill = "skyblue", color = "black") +
  facet_wrap(~ vendor) +
  theme_minimal() +
  labs(title = "Price Change Distribution by Vendor", 
       x = "Price Change", 
       y = "Frequency")

# Histogram of Price Changes
price_change_data |>
  mutate(price_change = round(price_change, 2)) |>
  ggplot(aes(x = price_change)) +
  geom_histogram(bins = 20, fill = "skyblue", color = "black") +
  theme_minimal() +
  labs(title = "Distribution of Price Changes for Dozen Eggs", 
       x = "Price Change", 
       y = "Frequency")

# Box Plot of Price Changes by Vendor
price_change_data |>
  mutate(price_change = round(price_change, 2)) |>
  ggplot(aes(x = vendor, y = price_change, fill = vendor)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Price Change Distribution by Vendor", 
       x = "Vendor", 
       y = "Price Change") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Line Plot of Price Change Over Time
price_change_data |>
  mutate(price_change = round(price_change, 2)) |>
  ggplot(aes(x = first_date, y = price_change, color = vendor)) +
  geom_line() +
  theme_minimal() +
  labs(title = "Price Change Over Time by Vendor", 
       x = "Date", 
       y = "Price Change")

#  Table Summarizing Price Changes
price_change_data |>
  group_by(vendor) |>
  summarize(
    mean_change = mean(price_change, na.rm = TRUE),
    median_change = median(price_change, na.rm = TRUE),
    min_change = min(price_change, na.rm = TRUE),
    max_change = max(price_change, na.rm = TRUE),
    occurences = n()
  ) |>
  arrange(mean_change)

# Correlation Between Price Change and Other Variables
cor_matrix <- cor(price_change_data[, sapply(price_change_data, is.numeric)], use = "complete.obs")
melted_cor_matrix <- melt(cor_matrix)
ggplot(melted_cor_matrix, aes(Var1, Var2, fill = value)) +
  geom_tile() +
  theme_minimal() +
  labs(title = "Correlation Matrix for Price Change Data") +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0)
