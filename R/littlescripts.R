#' Create example analysis scripts
#' @keywords internal
littlescripts <- function(path) {

  # 00_setup.R
  setup_script <- c(
    "# Initial Setup",
    "# Run this script first",
    "",
    "# Load packages",
    "source('R/setup.R')",
    "",
    "message('Setup complete. Ready for analysis!')"
  )
  writeLines(setup_script, file.path(path, "scripts/00_setup.R"))

  # 01_load_data.R
  load_script <- c(
    "# Load and Import Data",
    "",
    "library(tidyverse)",
    "library(here)",
    "",
    "# Load raw data",
    "# Example:",
    "# raw_data <- read_csv(here('data/raw/dataset.csv'))",
    "",
    "# View data structure",
    "# glimpse(raw_data)",
    "",
    "# Save to processed folder",
    "# saveRDS(raw_data, here('data/processed/loaded_data.rds'))",
    "",
    "message('Data loading complete!')"
  )
  writeLines(load_script, file.path(path, "scripts/01_load_data.R"))

  # 02_clean_data.R
  clean_script <- c(
    "# Data Cleaning and Processing",
    "",
    "library(tidyverse)",
    "library(here)",
    "",
    "# Load processed data",
    "# data <- readRDS(here('data/processed/loaded_data.rds'))",
    "",
    "# Clean data",
    "# cleaned_data <- data %>%",
    "#   filter(!is.na(important_column)) %>%",
    "#   mutate(new_column = some_transformation)",
    "",
    "# Save cleaned data",
    "# saveRDS(cleaned_data, here('data/processed/cleaned_data.rds'))",
    "",
    "message('Data cleaning complete!')"
  )
  writeLines(clean_script, file.path(path, "scripts/02_clean_data.R"))

  # 03_analyze_data.R
  analyze_script <- c(
    "# Data Analysis",
    "",
    "library(tidyverse)",
    "library(here)",
    "",
    "# Load cleaned data",
    "# data <- readRDS(here('data/processed/cleaned_data.rds'))",
    "",
    "# Perform analysis",
    "# results <- data %>%",
    "#   group_by(category) %>%",
    "#   summarise(",
    "#     mean_value = mean(value, na.rm = TRUE),",
    "#     n = n()",
    "#   )",
    "",
    "# Save results",
    "# write_csv(results, here('output/tables/summary_statistics.csv'))",
    "",
    "message('Analysis complete!')"
  )
  writeLines(analyze_script, file.path(path, "scripts/03_analyze_data.R"))

  # 04_visualize.R
  viz_script <- c(
    "# Data Visualization",
    "",
    "library(tidyverse)",
    "library(here)",
    "",
    "# Load data",
    "# data <- readRDS(here('data/processed/cleaned_data.rds'))",
    "",
    "# Create visualizations",
    "# plot <- ggplot(data, aes(x = x_var, y = y_var)) +",
    "#   geom_point() +",
    "#   theme_minimal() +",
    "#   labs(",
    "#     title = 'Your Plot Title',",
    "#     x = 'X Axis Label',",
    "#     y = 'Y Axis Label'",
    "#   )",
    "",
    "# Save plot",
    "# ggsave(",
    "#   here('output/figures/plot_name.png'),",
    "#   plot,",
    "#   width = 10,",
    "#   height = 6,",
    "#   dpi = 300",
    "# )",
    "",
    "message('Visualization complete!')"
  )
  writeLines(viz_script, file.path(path, "scripts/04_visualize.R"))

  message("Created example analysis scripts")
}
