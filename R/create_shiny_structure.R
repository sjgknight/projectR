#' Create Shiny App Structure
#'
#' Creates a complete Shiny app structure with best practices. Follows
#' Mastering Shiny guidelines (https://mastering-shiny.org/).
#'
#' @param path Character. Path where the Shiny app should be created
#' @param app_name Character. Name of the Shiny app (default: basename of path)
#' @param structure Character. App structure: "single" (app.R) or "multi" (ui.R + server.R).
#'   Default: "single"
#' @param include_modules Logical. Whether to create a modules/ subdirectory with
#'   example module template (default: TRUE)
#' @param include_golem Logical. If TRUE, adds golem-style structure comments
#'   (default: FALSE). See https://github.com/ThinkR-open/golem
#'
#' @details
#' Creates a production-ready Shiny app structure with:
#' \itemize{
#'   \item R/ directory for helper functions and modules
#'   \item www/ directory for static assets (CSS, JS, images)
#'   \item Example UI and server logic
#'   \item README with deployment instructions
#'   \item .gitignore configured for Shiny apps
#' }
#'
#' @section Deployment:
#' To deploy to shinyapps.io:
#' \preformatted{
#' library(rsconnect)
#' rsconnect::deployApp("path/to/app")
#' }
#'
#' @return Invisibly returns the app path
#' @export
#' @examples
#' \dontrun{
#' # Single-file app (simpler)
#' create_shiny_structure("myshinyapp", "My Shiny App")
#'
#' # Multi-file app with modules
#' create_shiny_structure("myshinyapp", "My App", structure = "multi", include_modules = TRUE)
#' }
create_shiny_structure <- function(
    path,
    app_name = basename(normalizePath(path, mustWork = FALSE)),
    structure = c("single", "multi"),
    include_modules = TRUE,
    include_golem = FALSE,
    git = TRUE,
    repo = NULL,
    languages = c("R"),
    renv = FALSE
) {

  structure <- match.arg(structure)

  # Create main directory
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }

  littlegit(path, git = git, repo = repo)

  if (git) {
    littlegitignore(path, languages, renv)
  }
  message("Initialized renv for project.")

  # Create subdirectories
  dirs <- c("www", "R")
  if (include_modules) {
    dirs <- c(dirs, "R/modules")
  }

  for (d in dirs) {
    dir.create(file.path(path, d), recursive = TRUE, showWarnings = FALSE)
  }

  if (git) {
    littlegitignore(path, languages)
  }

  # Header comments for golem structure
  golem_header <- if (include_golem) {
    c(
      "# See https://github.com/ThinkR-open/golem for golem framework",
      "# For production deployment, consider using golem::add_*() functions",
      ""
    )
  } else {
    NULL
  }

  if (structure == "single") {
    # Create app.R
    app_content <- c(
      "# Shiny App: ", app_name,
      "# Structure: Single-file (app.R)",
      "",
      golem_header,
      "# Load packages ----",
      "library(shiny)",
      "",
      "# Source helper functions ----",
      "source(\"R/utils.R\")",
      if (include_modules) "source(\"R/modules/example_module.R\")" else NULL,
      "",
      "# Define UI ----",
      "ui <- fluidPage(",
      "  ",
      "  # App title",
      paste0("  titlePanel(\"", app_name, "\"),"),
      "  ",
      "  # Sidebar layout",
      "  sidebarLayout(",
      "    ",
      "    # Sidebar panel",
      "    sidebarPanel(",
      "      ",
      "      # Input controls",
      "      sliderInput(",
      "        inputId = \"n\",",
      "        label = \"Number of observations:\",",
      "        min = 1,",
      "        max = 1000,",
      "        value = 500",
      "      ),",
      "      ",
      "      selectInput(",
      "        inputId = \"color\",",
      "        label = \"Choose color:\",",
      "        choices = c(\"steelblue\", \"coral\", \"forestgreen\"),",
      "        selected = \"steelblue\"",
      "      ),",
      "      ",
      "      # Action button",
      "      actionButton(\"update\", \"Update Plot\", class = \"btn-primary\")",
      "      ",
      "    ),",
      "    ",
      "    # Main panel",
      "    mainPanel(",
      "      ",
      "      # Output elements",
      "      tabsetPanel(",
      "        tabPanel(\"Plot\", plotOutput(\"distPlot\")),",
      "        tabPanel(\"Summary\", verbatimTextOutput(\"summary\")),",
      "        tabPanel(\"Table\", tableOutput(\"table\"))",
      "      )",
      "      ",
      "    )",
      "  )",
      ")",
      "",
      "# Define server logic ----",
      "server <- function(input, output, session) {",
      "  ",
      "  # Reactive data",
      "  data <- eventReactive(input$update, {",
      "    rnorm(input$n)",
      "  }, ignoreNULL = FALSE)  # Run on startup",
      "  ",
      "  # Plot output",
      "  output$distPlot <- renderPlot({",
      "    hist(",
      "      data(),",
      "      breaks = 30,",
      "      col = input$color,",
      "      border = \"white\",",
      paste0("      main = \"", app_name, " - Distribution\","),
      "      xlab = \"Value\",",
      "      ylab = \"Frequency\"",
      "    )",
      "  })",
      "  ",
      "  # Summary output",
      "  output$summary <- renderPrint({",
      "    summary(data())",
      "  })",
      "  ",
      "  # Table output",
      "  output$table <- renderTable({",
      "    data.frame(",
      "      Statistic = c(\"Mean\", \"SD\", \"Min\", \"Max\", \"N\"),",
      "      Value = c(",
      "        mean(data()),",
      "        sd(data()),",
      "        min(data()),",
      "        max(data()),",
      "        length(data())",
      "      )",
      "    )",
      "  })",
      "  ",
      "}",
      "",
      "# Run the application ----",
      "shinyApp(ui = ui, server = server)"
    )

    writeLines(app_content, file.path(path, "app.R"))

  } else {  # multi-file structure
    # Create ui.R
    ui_content <- c(
      "# UI Definition",
      "# See https://shiny.rstudio.com/reference/shiny/latest/ for reference",
      "",
      golem_header,
      "library(shiny)",
      "",
      "# Source helper functions",
      "source(\"R/utils.R\")",
      if (include_modules) "source(\"R/modules/example_module.R\")" else NULL,
      "",
      "# Define UI ----",
      "ui <- fluidPage(",
      "  ",
      "  # Include custom CSS",
      "  tags$head(",
      "    tags$link(rel = \"stylesheet\", type = \"text/css\", href = \"styles.css\")",
      "  ),",
      "  ",
      paste0("  titlePanel(\"", app_name, "\"),"),
      "  ",
      "  sidebarLayout(",
      "    ",
      "    sidebarPanel(",
      "      ",
      "      sliderInput(\"n\",",
      "                  \"Number of observations:\",",
      "                  min = 1,",
      "                  max = 1000,",
      "                  value = 500),",
      "      ",
      "      selectInput(\"color\",",
      "                  \"Choose color:\",",
      "                  choices = c(\"steelblue\", \"coral\", \"forestgreen\"),",
      "                  selected = \"steelblue\"),",
      "      ",
      "      actionButton(\"update\", \"Update Plot\", class = \"btn-primary\")",
      if (include_modules) c("      ", "      hr(),", "      ", "      # Example module", "      exampleModuleUI(\"example1\")") else NULL,
      "      ",
      "    ),",
      "    ",
      "    mainPanel(",
      "      ",
      "      tabsetPanel(",
      "        tabPanel(\"Plot\", plotOutput(\"distPlot\")),",
      "        tabPanel(\"Summary\", verbatimTextOutput(\"summary\")),",
      "        tabPanel(\"Table\", tableOutput(\"table\"))",
      "      )",
      "      ",
      "    )",
      "  )",
      ")"
    )

    writeLines(ui_content, file.path(path, "ui.R"))

    # Create server.R
    server_content <- c(
      "# Server Logic",
      "# See https://mastering-shiny.org/ for best practices",
      "",
      golem_header,
      "library(shiny)",
      "",
      "server <- function(input, output, session) {",
      "  ",
      "  # Reactive values",
      "  data <- eventReactive(input$update, {",
      "    rnorm(input$n)",
      "  }, ignoreNULL = FALSE)",
      "  ",
      "  # Outputs",
      "  output$distPlot <- renderPlot({",
      "    hist(data(),",
      "         breaks = 30,",
      "         col = input$color,",
      "         border = \"white\",",
      paste0("         main = \"", app_name, "\","),
      "         xlab = \"Value\",",
      "         ylab = \"Frequency\")",
      "  })",
      "  ",
      "  output$summary <- renderPrint({",
      "    summary(data())",
      "  })",
      "  ",
      "  output$table <- renderTable({",
      "    data.frame(",
      "      Statistic = c(\"Mean\", \"SD\", \"Min\", \"Max\", \"N\"),",
      "      Value = c(mean(data()), sd(data()), min(data()), max(data()), length(data()))",
      "    )",
      "  })",
      "  ",
      if (include_modules) c("  # Example module server", "  exampleModuleServer(\"example1\")", "  ") else NULL,
      "}"
    )

    writeLines(server_content, file.path(path, "server.R"))
  }

  # Create utils.R
  utils_content <- c(
    "# Utility Functions",
    "# Place reusable helper functions here",
    "",
    "#' Format a number with commas",
    "#'",
    "#' @param x Numeric value",
    "#' @return Formatted string",
    "format_number <- function(x) {",
    "  format(x, big.mark = \",\", scientific = FALSE)",
    "}",
    "",
    "#' Calculate summary statistics",
    "#'",
    "#' @param x Numeric vector",
    "#' @return Named list of statistics",
    "calc_summary <- function(x) {",
    "  list(",
    "    mean = mean(x, na.rm = TRUE),",
    "    sd = sd(x, na.rm = TRUE),",
    "    median = median(x, na.rm = TRUE),",
    "    min = min(x, na.rm = TRUE),",
    "    max = max(x, na.rm = TRUE)",
    "  )",
    "}"
  )

  writeLines(utils_content, file.path(path, "R/utils.R"))

  # Create example module if requested
  if (include_modules) {
    module_content <- c(
      "# Example Shiny Module",
      "# See https://mastering-shiny.org/scaling-modules.html for module best practices",
      "",
      "#' Example Module UI",
      "#'",
      "#' @param id Character. Module ID (namespace)",
      "#'",
      "#' @return Shiny UI elements",
      "exampleModuleUI <- function(id) {",
      "  ns <- NS(id)",
      "  ",
      "  tagList(",
      "    h4(\"Example Module\"),",
      "    textInput(ns(\"text\"), \"Enter text:\", placeholder = \"Type here...\"),",
      "    textOutput(ns(\"display\"))",
      "  )",
      "}",
      "",
      "#' Example Module Server",
      "#'",
      "#' @param id Character. Module ID (must match UI)",
      "#'",
      "#' @return Module server logic",
      "exampleModuleServer <- function(id) {",
      "  moduleServer(id, function(input, output, session) {",
      "    ",
      "    output$display <- renderText({",
      "      if (nchar(input$text) == 0) {",
      "        \"(no text entered)\"",
      "      } else {",
      "        paste(\"You entered:\", input$text)",
      "      }",
      "    })",
      "    ",
      "  })",
      "}"
    )

    writeLines(module_content, file.path(path, "R/modules/example_module.R"))
  }

  # Create README.md
  readme_content <- c(
    paste0("# ", app_name),
    "",
    "## Overview",
    "",
    "This is a Shiny web application built with R.",
    "",
    "## Running the App",
    "",
    "### Locally",
    "",
    "```r",
    "# Install required packages",
    "install.packages(c(\"shiny\"))",
    "",
    "# Run the app",
    if (structure == "single") "shiny::runApp(\"app.R\")" else "shiny::runApp()",
    "```",
    "",
    "### Deploy to shinyapps.io",
    "",
    "```r",
    "# Install deployment package",
    "install.packages(\"rsconnect\")",
    "",
    "# Configure account (first time only)",
    "rsconnect::setAccountInfo(",
    "  name = \"your-account\",",
    "  token = \"your-token\",",
    "  secret = \"your-secret\"",
    ")",
    "",
    "# Deploy",
    "rsconnect::deployApp()",
    "```",
    "",
    "## Structure",
    "",
    if (structure == "single") {
      c("- `app.R`: Main application file (UI + Server)")
    } else {
      c("- `ui.R`: User interface definition",
        "- `server.R`: Server logic")
    },
    "- `R/utils.R`: Utility functions",
    if (include_modules) "- `R/modules/`: Shiny modules for code organization" else NULL,
    "- `www/`: Static assets (CSS, JS, images)",
    "",
    "## Resources",
    "",
    "- [Mastering Shiny](https://mastering-shiny.org/)",
    "- [Shiny Reference](https://shiny.rstudio.com/reference/shiny/latest/)",
    "- [Shiny Gallery](https://shiny.rstudio.com/gallery/)",
    if (include_golem) "- [Golem Framework](https://github.com/ThinkR-open/golem)" else NULL
  )

  writeLines(readme_content, file.path(path, "README.md"))

  # Create .gitignore
  gitignore_content <- c(
    ".Rproj.user",
    ".Rhistory",
    ".RData",
    ".Ruserdata",
    "*.Rproj",
    "rsconnect/",
    ".DS_Store",
    "Thumbs.db"
  )

  writeLines(gitignore_content, file.path(path, ".gitignore"))

  # Create CSS file
  css_content <- c(
    "/* Custom styles for Shiny app */",
    "",
    "body {",
    "  padding-top: 20px;",
    "  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;",
    "}",
    "",
    ".well {",
    "  background-color: #f8f9fa;",
    "  border: 1px solid #dee2e6;",
    "}",
    "",
    ".btn-primary {",
    "  margin-top: 10px;",
    "}",
    "",
    "/* Responsive adjustments */",
    "@media (max-width: 768px) {",
    "  .col-sm-4, .col-sm-8 {",
    "    width: 100%;",
    "  }",
    "}"
  )

  writeLines(css_content, file.path(path, "www/styles.css"))

  message("\nShiny app structure created successfully at: ", normalizePath(path))
  message("\n", paste(rep("=", 60), collapse = ""))
  message("Structure: ", structure, "-file (", if (structure == "single") "app.R" else "ui.R + server.R", ")")
  message("Modules: ", if (include_modules) "Yes" else "No")
  message(paste(rep("=", 60), collapse = ""))
  message("\nNext steps:")
  message("1. Customize the UI in ", if (structure == "single") "app.R" else "ui.R")
  message("2. Add your server logic in ", if (structure == "single") "app.R" else "server.R")
  message("3. Add utility functions to R/utils.R")
  if (include_modules) message("4. Create additional modules in R/modules/")
  message(if (include_modules) "5" else "4", ". Add static assets (CSS, images) to www/")
  message(if (include_modules) "6" else "5", ". Test with: shiny::runApp()")
  message("\nResources:")
  message("  - Mastering Shiny: https://mastering-shiny.org/")
  message("  - Shiny modules: https://mastering-shiny.org/scaling-modules.html")
  message("  - Deploy to shinyapps.io: https://www.shinyapps.io/")

  invisible(normalizePath(path))
}
