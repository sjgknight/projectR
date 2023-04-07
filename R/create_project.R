#' Create a new R project
#'
#' This function creates a new R project with a default directory structure,
#' gitignore templates, and a setup.R script in the R directory.
#' @param path The path to create the project in.
#' @param git Logical value indicating whether to initialize a Git repository.
#' @param repo The name of a GitHub repository to clone to create the project.
#' @param languages A character vector of languages to include in the gitignore file.
#' @param renv Logical value indicating whether to initialize an R environment.
#' @return A message indicating whether the project was created successfully.
#' @importFrom pacman p_load p_load_gh
#' @importFrom usethis create_project create_from_github use_git
#' @importFrom gitignore gi_fetch_templates gi_write_gitignore
#' @importFrom git2r init remote_add
#' @importFrom utils install.packages
#' @export
create_projectR <- function(path, git = FALSE, repo = NULL, languages = c("R"), renv = FALSE) {
  # Create project directory
  if (git && is.null(repo)) {
    usethis::create_project(path, open = FALSE)
    git2r::init(path)
  } else if (git) {
    usethis::create_from_github(path, repo)
  } else {
    usethis::create_project(path, open = FALSE)
  }

  # Add gitignore templates and create directories
  gitignore::gi_write_gitignore(c(
    gitignore::gi_fetch_templates(languages),
    "*.ini"),
    gitignore_file = paste0(path,"/.gitignore"))

  data <- file.path(path, "data")
  R <- file.path(path, "R")
  output <- file.path(path, "output")

  dir.create(data)
  dir.create(R)
  dir.create(output)

  # Install and load pacman package
  if (!require("pacman")) {
    install.packages("pacman")
  }

  # Create setup.R script in R directory
  setup_file <- file.path(R, "setup.R")
  writeLines("pacman::p_load(here)\n
              #you might want to run use_git() to initiate a git repo here\n
              usethis::use_git()\n", setup_file)

  # Create README file with project setup information
  readme_file <- file.path(path, "README.md")
  readme_text <- "This is an R project created with projectR. \

  It includes a default directory structure, gitignore templates, and a setup.R script \
  in the R directory. To use this script, run `source('R/setup.R')` from the project directory. \

  To connect to GitHub, run `usethis::use_github()` or `usethis::use_git()`. \

  You should check the LICENSE file, you might want to use an opensource license such as the MIT license,
  you might find https://choosealicense.com/licenses/ or similar helpful"
  writeLines(readme_text, readme_file)

  # Create LICENSE file with link to license information
  license_file <- file.path(path, "LICENSE")
  license_text <- "No license selected yet"
  writeLines(license_text, license_file)

  message("Project created successfully.")
}