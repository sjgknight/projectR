#' Create R Project Structure
#'
#' Master function to create different types of R projects with appropriate structure.
#' Can create vanilla analysis projects, R packages, or Shiny applications.
#'
#' @param path Character. Path where the project should be created
#' @param project_name Character. Name of the project (default: basename of path)
#' @param project_type Character. Type of project: "vanilla" (default), "package", or "shinyapp"
#' @param ... Additional arguments passed to specific creation functions:
#'   \itemize{
#'     \item For "package": author_name, author_email, title, description, license, create_logo
#'     \item For "shinyapp": structure, include_modules, include_golem
#'     \item For "vanilla": include_renv, create_scripts
#'   }
#'
#' @details
#' This is a wrapper function that creates the appropriate project structure:
#'
#' \strong{Vanilla Projects} (project_type = "vanilla"):
#' Creates a data analysis project with:
#' \itemize{
#'   \item data/raw/ and data/processed/ for data files
#'   \item scripts/ for numbered analysis scripts (00_setup.R, 01_load_data.R, etc.)
#'   \item output/ for figures, tables, and reports
#'   \item Optional renv for dependency management
#' }
#'
#' \strong{R Packages} (project_type = "package"):
#' Creates a full R package structure. After creation, use:
#' \itemize{
#'   \item \code{usethis::use_package("packagename")} - Add dependencies
#'   \item \code{usethis::use_r("function_name")} - Create new function file
#'   \item \code{usethis::use_test("function_name")} - Create test file
#'   \item \code{usethis::use_vignette("article_name")} - Add vignette
#'   \item \code{usethis::use_data(dataset)} - Add data to package
#'   \item \code{usethis::use_data_raw("dataset")} - Create data-raw/ script
#'   \item \code{devtools::document()} - Update documentation
#'   \item \code{devtools::check()} - Check package
#'   \item \code{devtools::test()} - Run tests
#'   \item \code{devtools::build()} - Build package
#' }
#'
#' Development files that won't be bundled with the package:
#' \itemize{
#'   \item data-raw/ - Scripts for creating package datasets (add to .Rbuildignore)
#'   \item docs/ - pkgdown website files (add to .Rbuildignore)
#'   \item vignettes/ - Long-form documentation (bundled, but can add specific files to .Rbuildignore)
#'   \item inst/ - Files installed with package (inst/extdata/ for example data)
#'   \item Add any file/folder to .Rbuildignore to exclude from build
#' }
#'
#' \strong{Shiny Apps} (project_type = "shinyapp"):
#' Creates a Shiny web application.
#'
#' @section Package Development Resources:
#' \itemize{
#'   \item R Packages (2nd ed): https://r-pkgs.org/
#'   \item usethis reference: https://usethis.r-lib.org/reference/index.html
#'   \item devtools reference: https://devtools.r-lib.org/reference/index.html
#'   \item pkgdown (package website): https://pkgdown.r-lib.org/
#'   \item roxygen2 (documentation): https://roxygen2.r-lib.org/
#'   \item testthat (testing): https://testthat.r-lib.org/
#' }
#'
#' @return Invisibly returns the project path
#' @export
#' @examples
#' \dontrun{
#' # Create a vanilla analysis project
#' create_project("myAnalysis", project_type = "vanilla", include_renv = TRUE)
#'
#' # Create an R package
#' create_project(
#'   "myPackage",
#'   project_type = "package",
#'   author_name = "Your Name",
#'   author_email = "you@example.com",
#'   create_logo = TRUE
#' )
#'
#' # Create a Shiny app
#' create_project(
#'   "myShinyApp",
#'   project_type = "shinyapp",
#'   structure = "multi",
#'   include_modules = TRUE
#' )
#' }
create_project <- function(
    path,
    project_name = basename(normalizePath(path, mustWork = FALSE)),
    project_type = c("vanilla", "package", "shinyapp"),
    ...
) {

  project_type <- match.arg(project_type)

  message("\n", paste(rep("=", 70), collapse = ""))
  message("Creating ", toupper(project_type), " project: ", project_name)
  message("Location: ", normalizePath(path, mustWork = FALSE))
  message(paste(rep("=", 70), collapse = ""))
  message("")

  result <- switch(
    project_type,

    package = {
      # Check if usethis/devtools are available
      if (requireNamespace("usethis", quietly = TRUE) &&
          requireNamespace("devtools", quietly = TRUE)) {
        message("Note: usethis and devtools are available for package development")
        message("      Use their functions for efficient package development\n")
      } else {
        message("Note: Install usethis and devtools for easier package development:")
        message("      install.packages(c('usethis', 'devtools'))\n")
      }

      create_package_structure(
        path = path,
        package_name = project_name,
        ...
      )
    },

    shinyapp = {
      create_shiny_structure(
        path = path,
        app_name = project_name,
        ...
      )
    },

    vanilla = {
      create_data_structure(
        path = path,
        project_name = project_name,
        ...
      )
    }
  )

  message("\n", paste(rep("=", 70), collapse = ""))
  message("PROJECT CREATED SUCCESSFULLY!")
  message(paste(rep("=", 70), collapse = ""))

  # Project-specific next steps
  if (project_type == "package") {
    message("\nPackage Development Workflow:")
    message("  1. Add functions: usethis::use_r('function_name')")
    message("  2. Add dependencies: usethis::use_package('packagename')")
    message("  3. Document: devtools::document()")
    message("  4. Test: devtools::test()")
    message("  5. Check: devtools::check()")
    message("\nDevelopment files (not bundled with package):")
    message("  - data-raw/     Scripts to create package data")
    message("  - docs/         pkgdown website (use usethis::use_pkgdown())")
    message("  - Any files added to .Rbuildignore")
    message("\nLearn more:")
    message("  - R Packages book: https://r-pkgs.org/")
    message("  - usethis: https://usethis.r-lib.org/")
    message("  - devtools: https://devtools.r-lib.org/")

  } else if (project_type == "shinyapp") {
    message("\nShiny App Workflow:")
    message("  1. Run app: shiny::runApp()")
    message("  2. Deploy: rsconnect::deployApp()")
    message("\nLearn more:")
    message("  - Mastering Shiny: https://mastering-shiny.org/")
    message("  - Gallery: https://shiny.rstudio.com/gallery/")

  } else {  # vanilla
    message("\nAnalysis Workflow:")
    message("  1. Run: source('scripts/00_setup.R')")
    message("  2. Add data to: data/raw/")
    message("  3. Follow numbered scripts in order")
    message("\nBest practices:")
    message("  - Keep raw data immutable")
    message("  - Save processed data to data/processed/")
    message("  - Use relative paths (consider 'here' package)")
  }
}

