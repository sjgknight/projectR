#' Serialize R Package to Single File
#'
#' Reads all files from an R package directory and combines them into a single
#' serialized file with metadata, suitable for sharing with LLMs like Claude.
#'
#' @param package_dir Character. Path to the R package directory
#' @param output_file Character. Path for the output serialized file (default: package_name_serialized.txt)
#' @param include_patterns Character vector. File patterns to include (default: R and Rmd files)
#' @param exclude_patterns Character vector. Patterns to exclude (default: common non-essential files)
#' @param max_file_size Integer. Maximum file size in bytes to include (default: 1MB)
#'
#' @return Invisibly returns the output file path
#' @examples
#' \dontrun{
#' serialize_package("path/to/mypackage")
#' serialize_package(".", output_file = "custom_name.txt")
#' }
serialize_package <- function(
    package_dir,
    output_file = NULL,
    include_patterns = c("\\.R$", "\\.Rmd$", "\\.md$", "^DESCRIPTION$", "^NAMESPACE$", "^LICENSE$^", "\\.gitignore$"),
     exclude_patterns = c("\\.Rproj$", "\\.Rhistory$", "\\.RData$", "\\.DS_Store$", "^\\.git", "^\\.Rbuildignore","^man/", "^docs/", "^tests/testthat/_snaps/"),
    max_file_size = 1048576  # 1MB default
) {


  # Validate package directory
  if (!dir.exists(package_dir)) {
    stop("Package directory does not exist: ", package_dir)
  }

  # Get package name from DESCRIPTION or directory name
  desc_file <- file.path(package_dir, "DESCRIPTION")
  if (file.exists(desc_file)) {
    desc <- read.dcf(desc_file)
    pkg_name <- desc[1, "Package"]
  } else {
    pkg_name <- basename(package_dir)
  }

  # Set default output file if not specified
  if (is.null(output_file)) {
    output_file <- paste0(pkg_name, "_serialized.txt")
  }

  # Find all files recursively
  all_files <- list.files(
    package_dir,
    recursive = TRUE,
    full.names = TRUE,
    all.files = FALSE
  )

  # Filter files based on patterns
  included_files <- all_files

  # Apply include patterns
  if (length(include_patterns) > 0) {
    include_regex <- paste(include_patterns, collapse = "|")
    included_files <- included_files[grepl(include_regex, basename(included_files))]
  }

  # Apply exclude patterns
  if (length(exclude_patterns) > 0) {
    exclude_regex <- paste(exclude_patterns, collapse = "|")
    included_files <- included_files[!grepl(exclude_regex, included_files)]
  }

  # Filter by file size
  file_sizes <- file.info(included_files)$size
  included_files <- included_files[file_sizes <= max_file_size]

  # Get relative paths
  # Normalize paths and escape special regex characters (especially backslashes on Windows)
  norm_pkg_dir <- normalizePath(package_dir, winslash = "/")
  norm_files <- normalizePath(included_files, winslash = "/")

  # Create regex pattern with escaped special characters
  pattern <- paste0("^", gsub("([\\.|\\(|\\)|\\[|\\]|\\{|\\}|\\^|\\$|\\*|\\+|\\?])", "\\\\\\1", norm_pkg_dir), "/?")

  rel_paths <- gsub(pattern, "", norm_files)

  # Create metadata
  metadata <- data.frame(
    file_path = rel_paths,
    full_path = included_files,
    file_size = file_sizes[file_sizes <= max_file_size],
    stringsAsFactors = FALSE
  )

  # Sort by path for organization
  metadata <- metadata[order(metadata$file_path), ]

  message("Found ", nrow(metadata), " files to serialize")
  message("Total size: ", format(sum(metadata$file_size), big.mark = ","), " bytes")

  # Open output file
  out_con <- file(output_file, "w")

  tryCatch({
    # Write header
    writeLines(paste(rep("=", 80), collapse = ""), out_con)
    writeLines(paste("R PACKAGE SERIALIZATION:", pkg_name), out_con)
    writeLines(paste("Generated:", Sys.time()), out_con)
    writeLines(paste("Total files:", nrow(metadata)), out_con)
    writeLines(paste("Package directory:", package_dir), out_con)
    writeLines(paste(rep("=", 80), collapse = ""), out_con)
    writeLines("", out_con)

    # Write table of contents
    writeLines("TABLE OF CONTENTS", out_con)
    writeLines(paste(rep("-", 80), collapse = ""), out_con)
    for (i in 1:nrow(metadata)) {
      writeLines(
        sprintf("%3d. %s (%s bytes)", i, metadata$file_path[i],
                format(metadata$file_size[i], big.mark = ",")),
        out_con
      )
    }
    writeLines("", out_con)
    writeLines(paste(rep("=", 80), collapse = ""), out_con)
    writeLines("", out_con)

    # Write each file with metadata
    for (i in 1:nrow(metadata)) {
      file_path <- metadata$file_path[i]
      full_path <- metadata$full_path[i]

      message("Processing [", i, "/", nrow(metadata), "]: ", file_path)

      # Write file header
      writeLines("", out_con)
      writeLines(paste(rep("#", 80), collapse = ""), out_con)
      writeLines(paste("# FILE:", file_path), out_con)
      writeLines(paste("# SIZE:", format(metadata$file_size[i], big.mark = ","), "bytes"), out_con)
      writeLines(paste("# INDEX:", i), out_con)
      writeLines(paste(rep("#", 80), collapse = ""), out_con)
      writeLines("", out_con)

      # Read and write file content
      tryCatch({
        # Try to read as text
        content <- readLines(full_path, warn = FALSE)
        writeLines(content, out_con)
      }, error = function(e) {
        writeLines(paste("# ERROR READING FILE:", e$message), out_con)
      })

      # Write file footer
      writeLines("", out_con)
      writeLines(paste("# END OF FILE:", file_path), out_con)
      writeLines(paste(rep("#", 80), collapse = ""), out_con)
      writeLines("", out_con)
    }

    # Write summary footer
    writeLines("", out_con)
    writeLines(paste(rep("=", 80), collapse = ""), out_con)
    writeLines("END OF SERIALIZATION", out_con)
    writeLines(paste("Total files processed:", nrow(metadata)), out_con)
    writeLines(paste("Output file:", output_file), out_con)
    writeLines(paste(rep("=", 80), collapse = ""), out_con)

  }, finally = {
    close(out_con)
  })

  message("\nSerialization complete!")
  message("Output file: ", output_file)
  message("File size: ", format(file.info(output_file)$size, big.mark = ","), " bytes")

  invisible(output_file)
}
