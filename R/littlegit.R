#' Lightweight Git project bootstrap
#'
#' Initializes a project directory with optional Git support,
#' optionally cloning from GitHub.
#'
#' @param path Character. Path to project root
#' @param git Logical. Whether to use Git
#' @param repo Character or NULL. GitHub repo spec "user/repo"
#'
#' @return Invisibly returns normalized project path
#' @export
littlegit <- function(path, git = TRUE, repo = NULL) {

  path <- normalizePath(path, winslash = "/", mustWork = FALSE)

  if (git && !is.null(repo)) {

    if (!requireNamespace("usethis", quietly = TRUE)) {
      stop("usethis package required to clone from GitHub")
    }

    usethis::create_from_github(
      repo_spec = repo,
      destdir = dirname(path),
      fork = FALSE,
      open = FALSE
    )

    message("Created project from GitHub repository: ", repo)

  } else if (git) {

    if (requireNamespace("usethis", quietly = TRUE)) {
      usethis::create_project(path, open = FALSE)

      if (requireNamespace("git2r", quietly = TRUE)) {
        git2r::init(path, branch = "main", bare = FALSE)
        message("Initialized Git repository with branch 'main'")
      } else {
        message("git2r not available; Git not initialized")
      }

    } else {
      dir.create(path, recursive = TRUE)
      message("usethis not available; created directory only")
    }

  } else {

    if (requireNamespace("usethis", quietly = TRUE)) {
      usethis::create_project(path, open = FALSE)
      message("Created project without Git")
    } else {
      dir.create(path, recursive = TRUE)
      message("Created directory")
    }
  }

  invisible(normalizePath(path))
}
