#' Deserialize Package Files
#'
#' Extract files from a serialized package file back to a directory structure
#'
#' @param serialized_file Character. Path to the serialized file
#' @param output_dir Character. Directory to extract files to (default: current directory)
#' @param overwrite Logical. Whether to overwrite existing files (default: FALSE)
#'
#' @return Invisibly returns the output directory path
#' @export
#' @examples
#' \dontrun{
#' deserialize_package("mypackage_serialized.txt", output_dir = "restored_package")
#' }
deserialize_package <- function(
    serialized_file,
    output_dir = ".",
    overwrite = FALSE
) {

  if (!file.exists(serialized_file)) {
    stop("Serialized file does not exist: ", serialized_file)
  }

  # Read entire file
  all_lines <- readLines(serialized_file, warn = FALSE)

  # Find file boundaries
  file_starts <- grep("^# FILE:", all_lines)

  if (length(file_starts) == 0) {
    stop("No files found in serialized file")
  }

  message("Found ", length(file_starts), " files to extract")

  # Extract each file
  for (i in seq_along(file_starts)) {
    start_idx <- file_starts[i]

    # Extract file path from header
    file_path_line <- all_lines[start_idx]
    file_path <- sub("^# FILE: ", "", file_path_line)

    # Find content start (after header)
    content_start <- start_idx + 1
    while (content_start <= length(all_lines) &&
           grepl("^#", all_lines[content_start])) {
      content_start <- content_start + 1
    }
    content_start <- content_start + 1  # Skip blank line

    # Find content end (before next file or end)
    if (i < length(file_starts)) {
      content_end <- file_starts[i + 1] - 1
    } else {
      content_end <- length(all_lines)
    }

    # Find actual end marker
    end_marker <- grep("^# END OF FILE:", all_lines[content_start:content_end])
    if (length(end_marker) > 0) {
      content_end <- content_start + end_marker[1] - 2
    }

    # Extract content
    content <- all_lines[content_start:content_end]
    # Remove trailing empty lines
    while (length(content) > 0 && content[length(content)] == "") {
      content <- content[-length(content)]
    }

    # Create output path
    output_path <- file.path(output_dir, file_path)

    # Create directory if needed
    output_file_dir <- dirname(output_path)
    if (!dir.exists(output_file_dir)) {
      dir.create(output_file_dir, recursive = TRUE)
    }

    # Check if file exists
    if (file.exists(output_path) && !overwrite) {
      message("Skipping (already exists): ", file_path)
      next
    }

    # Write file
    message("Extracting [", i, "/", length(file_starts), "]: ", file_path)
    writeLines(content, output_path)
  }

  message("\nDeserialization complete!")
  message("Files extracted to: ", output_dir)

  invisible(output_dir)
}
