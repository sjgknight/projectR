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
#' @import pacman
#' @importFrom usethis create_project create_from_github use_git
#' @importFrom gitignore gi_fetch_templates gi_write_gitignore
#' @importFrom git2r init remote_add
#' @importFrom utils install.packages
#' @export
create_projectR <- function(path, git = FALSE, repo = NULL, languages = c("R"), renv = FALSE) {
  # safe path - we're going to assume the user - probably me - is an idiot copy-pasting from explorer with windows paths

  # Normalize the path for compatibility
  #path <- normalizePath(path, winslash = "/", mustWork = FALSE)

  # Ensure the path is not already in use
  if (dir.exists(path)) stop("The directory already exists. Please provide a new path.")

  # Create project directory
  if (git && is.null(repo)) {
    usethis::create_project(path, open = FALSE)
    git2r::init(path, "main", bare = FALSE)
	message("Initialized a project with Git repository with the default branch 'main'.")
  } else if (git) {
    usethis::create_from_github(destdir = path, repo_spec = repo)
    message("Initialized a project with git from a github repository.")
  } else {
    usethis::create_project(path, open = FALSE)
    message("Initialized a project without git.")
  }


  # Add gitignore templates and create directories
  gitignore_path <- file.path(path, ".gitignore")

  gi_content <- c(gitignore::gi_fetch_templates(languages), "\n*.ini")

  gitignore::gi_write_gitignore(gi_content,
    gitignore_file = gitignore_path)

  # setup renv
  if (renv) {renv::init(project = path)}
    message("Initialized renv for project.")

  # Create useful directory structure
  datadir <- file.path(path, "data")
  Rdir <- file.path(path, "R")
  outputdir <- file.path(path, "output")

  dir.create(datadir)
  dir.create(Rdir)
  dir.create(outputdir)

  # Install and load pacman package
  if (!require("pacman")) {
    install.packages("pacman")
  }

  # Create setup.R script in R directory
  setup_file <- file.path(Rdir, "setup.R")
  writeLines("pacman::p_load(here)\n
              #you might want to run use_git() to initiate a git repo here\n
              usethis::use_git()\n", setup_file)

  # Create README file with project setup information
  readme_file <- file.path(path, "README.md")
  readme_text <- "This is an R project created with projectR. \n

  It includes a default directory structure, gitignore templates, and a setup.R script \n
  in the R directory. To use this script, run `source('R/setup.R')` from the project directory. \n

  To connect to GitHub, run `usethis::use_github()` or `usethis::use_git()`. \n

  You should check the LICENSE file, you might want to use an opensource license such as the MIT license,
  you might find https://choosealicense.com/licenses/ or similar helpful"
  writeLines(readme_text, readme_file)

  # Create LICENSE file with link to license information
  license_file <- file.path(path, "LICENSE")
  license_text <- "No license selected yet"
  writeLines(license_text, license_file)

  message("Project created successfully.")
}
