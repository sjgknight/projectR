#' Create Vanilla R Project Structure
#'
#' Creates a comprehensive R project structure for data analysis work. Builds on
#' the original projectR function with enhanced features for reproducible research.
#'
#' @param path Character. Path where the project should be created
#' @param project_name Character. Name of the project (default: basename of path)
#' @param git Logical. Whether to initialize a Git repository (default: FALSE)
#' @param repo Character. GitHub repository to clone (format: "username/repo").
#'   If provided, creates project from this repo instead of from scratch (default: NULL)
#' @param languages Character vector. Languages to include in .gitignore file
#'   (default: c("R")). Uses gitignore package templates.
#' @param include_renv Logical. Whether to initialize renv for dependency management
#'   (default: FALSE)
#' @param create_scripts Logical. Whether to create example script templates
#'   (default: TRUE)
#'
#' @details
#' Creates a structured analysis project with:
#' \itemize{
#'   \item \strong{data/raw/} - Original, immutable data files
#'   \item \strong{data/processed/} - Cleaned, transformed data
#'   \item \strong{R/} - Reusable R functions and setup scripts
#'   \item \strong{scripts/} - Analysis scripts (numbered workflow)
#'   \item \strong{output/} - Results (figures/, tables/, reports/)
#'   \item \strong{docs/} - Documentation
#'   \item README.md, LICENSE, .gitignore
#' }
#'
#' If \code{git = TRUE}, initializes a Git repository with branch 'main'.
#' If \code{repo} is provided, clones from GitHub instead.
#'
#' @section Using with Git:
#' To connect to GitHub after creation:
#' \preformatted{
#' usethis::use_github()  # Creates GitHub repo and connects
#' # OR manually:
#' # git remote add origin https://github.com/username/repo.git
#' # git push -u origin main
#' }
#'
#' @section Dependencies:
#' Optional packages enhance functionality:
#' \itemize{
#'   \item \code{usethis} - Project and Git setup
#'   \item \code{gitignore} - Language-specific .gitignore templates
#'   \item \code{git2r} - Git operations from R
#'   \item \code{renv} - Dependency management
#'   \item \code{here} - Relative path handling
#' }
#'
#' @return Invisibly returns the project path
#' @export
#' @examples
#' \dontrun{
#' # Basic project
#' create_data_structure("myproject", "My Analysis")
#'
#' # With Git and renv
#' create_data_structure(
#'   "myproject",
#'   git = TRUE,
#'   include_renv = TRUE
#' )
#'
#' # From GitHub repository
#' create_data_structure(
#'   "myproject",
#'   git = TRUE,
#'   repo = "username/repository"
#' )
#' }
create_data_structure <- function(
    path,
    project_name = basename(normalizePath(path, mustWork = FALSE)),
    git = TRUE,
    repo = NULL,
    languages = c("R"),
    renv = FALSE,
    create_scripts = TRUE
) {

  # Normalize the path for cross-platform compatibility
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)

  # Check if directory already exists
  if (dir.exists(path)) {
    stop("The directory already exists. Please provide a new path or remove existing directory.")
  }

  littlegit(path, git = git, repo = repo)

  if (renv) {
    renv::init(project = path)
  }
  message("Initialized renv for project.")

  # Create directory structure
  dirs <- c(
    "data/raw",
    "data/processed",
    "R",
    "scripts",
    "output/figures",
    "output/tables",
    "output/reports",
    "docs"
  )

  for (d in dirs) {
    dir.create(file.path(path, d), recursive = TRUE, showWarnings = FALSE)
  }

  message("Created directory structure")

  if (git) {
    littlegitignore(path, languages, renv)
    }

  # Create setup.R script in R directory
  setup_content <- c(
    "# Project Setup Script",
    "# Run this first to configure the project environment",
    "",
    "# Install and load pacman for package management",
    "if (!require('pacman', quietly = TRUE)) {",
    "  install.packages('pacman')",
    "}",
    "",
    "# Load essential packages",
    "pacman::p_load(",
    "  here,      # For relative paths",
    "  tidyverse  # Data manipulation and visualization",
    ")",
    "",
    "# Set project options",
    "options(",
    "  stringsAsFactors = FALSE,",
    "  scipen = 999",
    ")",
    "",
    "# Additional recommended packages",
    "# pacman::p_load(",
    "#   readr,     # Reading data",
    "#   ggplot2,   # Plotting",
    "#   dplyr,     # Data manipulation",
    "#   janitor    # Data cleaning",
    "# )",
    "",
    if (git) c(
      "# Git setup (if not already done)",
      "# Note: Run these interactively, not in source()",
      "# usethis::use_git()  # Initialize Git if needed",
      "# usethis::use_github()  # Connect to GitHub",
      ""
    ) else NULL,
    "# Create output directories if they don't exist",
    "dir.create('output/figures', recursive = TRUE, showWarnings = FALSE)",
    "dir.create('output/tables', recursive = TRUE, showWarnings = FALSE)",
    "dir.create('output/reports', recursive = TRUE, showWarnings = FALSE)",
    "",
    "message('Project setup complete!')",
    "message('Working directory: ', here::here())"
  )

  writeLines(setup_content, file.path(path, "R/setup.R"))

  # Create example analysis scripts if requested
  if (create_scripts) {
    littlescripts(path)
  }

  structure_lines <- c(
    "|-- data/",
    "|   |-- raw/          # Original, immutable data",
    "|   `-- processed/    # Cleaned, transformed data",
    "|-- R/",
    "|   `-- setup.R       # Project setup and configuration",
    "|-- scripts/          # Analysis scripts (run in order)",
    "|   |-- 00_setup.R",
    "|   |-- 01_load_data.R",
    "|   |-- 02_clean_data.R",
    "|   |-- 03_analyze_data.R",
    "|   `-- 04_visualize.R",
    "|-- output/",
    "|   |-- figures/      # Plots and visualizations",
    "|   |-- tables/       # Analysis tables",
    "|   `-- reports/      # Generated reports",
    "`-- docs/             # Documentation"
  )

  # Create README
  readme_content <- c(
    paste0("# ", project_name),
    "",
    "## Overview",
    "",
    "This R project was created with a structured workflow for data analysis.",
    "",
    "## Project Structure",
    "",
    "```",
    structure_lines, # Documentation",
    "```",
    "",
    "## Getting Started",
    "",
    "1. Run the setup script:",
    "   ```r",
    "   source('R/setup.R')",
    "   ```",
    "",
    "2. Place your raw data in `data/raw/`",
    "",
    "3. Run analysis scripts in order:",
    "   ```r",
    "   source('scripts/01_load_data.R')",
    "   source('scripts/02_clean_data.R')",
    "   source('scripts/03_analyze_data.R')",
    "   source('scripts/04_visualize.R')",
    "   ```",
    "",
    if (git) c(
      "## Git & GitHub",
      "",
      "To connect this project to GitHub:",
      "",
      "```r",
      "usethis::use_github()",
      "```",
      "",
      "Or manually:",
      "",
      "```bash",
      "git remote add origin https://github.com/username/repository.git",
      "git branch -M main",
      "git push -u origin main",
      "```",
      ""
    ) else NULL,
    "## Requirements",
    "",
    "- R >= 4.0.0",
    "- Required packages: tidyverse, here",
    if (include_renv) "- Package versions managed by renv" else NULL,
    "",
    "## License",
    "",
    "See LICENSE file. Consider choosing an open source license:",
    "- https://choosealicense.com/",
    "",
    "## Resources",
    "",
    "- [R for Data Science](https://r4ds.had.co.nz/)",
    "- [Project-oriented workflow](https://www.tidyverse.org/blog/2017/12/workflow-vs-script/)",
    "- [here package](https://here.r-lib.org/)"
  )

  writeLines(readme_content, file.path(path, "README.md"))

  # Create LICENSE file
  license_content <- c(
    "No license selected yet",
    "",
    "Consider choosing an open source license:",
    "- MIT License: https://choosealicense.com/licenses/mit/",
    "- GPL-3.0: https://choosealicense.com/licenses/gpl-3.0/",
    "- Apache 2.0: https://choosealicense.com/licenses/apache-2.0/",
    "",
    "Or use usethis to add a license:",
    "  usethis::use_mit_license('Your Name')",
    "  usethis::use_gpl3_license()",
    "  usethis::use_apache_license()"
  )

  writeLines(license_content, file.path(path, "LICENSE"))

  # Initialize renv if requested
  if (include_renv) {
    if (requireNamespace("renv", quietly = TRUE)) {
      tryCatch({
        current_dir <- getwd()
        setwd(path)
        renv::init(bare = TRUE, restart = FALSE)
        setwd(current_dir)
        message("Initialized renv for dependency management")
      }, error = function(e) {
        message("Note: renv initialization encountered an error: ", e$message)
        message("You can initialize renv manually later with: renv::init()")
      })
    } else {
      message("renv package not available. Install with: install.packages('renv')")
    }
  }

  message("\n", paste(rep("=", 60), collapse = ""))
  message("VANILLA PROJECT CREATED SUCCESSFULLY")
  message(paste(rep("=", 60), collapse = ""))
  message("\nProject location: ", path)
  message("\nNext steps:")
  message("  1. source('R/setup.R')  # Install packages and configure")
  message("  2. Add your data to data/raw/")
  message("  3. Run scripts in order (01_, 02_, etc.)")
  if (git && is.null(repo)) {
    message("  4. usethis::use_github()  # Connect to GitHub")
  }
  if (include_renv) {
    message("  ", if (git && is.null(repo)) "5" else "4",
            ". renv::snapshot()  # Save package versions")
  }

  invisible(normalizePath(path))
}
