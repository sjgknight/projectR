#' Create .gitignore with optional templates
#' @export
littlegitignore <- function(
    path,
    languages = c("R"),
    renv = FALSE
) {

  gitignore_path <- file.path(path, ".gitignore")

  if (requireNamespace("gitignore", quietly = TRUE)) {

      gi_content <- c(
        gitignore::gi_fetch_templates(languages),
        "",
        "# Project specific",
        "*.ini",
        "",
        "# Data files",
        "# data/raw/*",
        "# data/processed/*",
        "",
        "# Output",
        "output/*",
        "!output/.gitkeep",
        ".DS_Store",
        "Thumbs.db",
        "",
        if (include_renv) c(
          "# renv",
          "renv/library/",
          "renv/local/",
          "renv/staging/",
          ""
        ) else "# renv/\n"
      )

      gitignore::gi_write_gitignore(
        gi_content,
        gitignore_file = gitignore_path
      )

      # Create .gitkeep files to preserve empty directories in Git
      writeLines("", file.path(path, "data/raw/.gitkeep"))
      writeLines("", file.path(path, "data/processed/.gitkeep"))
      writeLines("", file.path(path, "output/figures/.gitkeep"))
      writeLines("", file.path(path, "output/tables/.gitkeep"))
      writeLines("", file.path(path, "output/reports/.gitkeep"))

      message("Created .gitignore using templates: ",
              paste(languages, collapse = ", "))

  } else {
    message("needs gitignore")
  }

  invisible(gitignore_path)
}
