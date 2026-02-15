#' Create Package Logo Template
#'
#' Creates an SVG logo template for an R package in the standard location
#' (man/figures/logo.svg). The logo uses a hexagon shape which is standard
#' for R packages.
#'
#' @param package_path Character. Path to the package directory
#' @param package_name Character. Name of the package (used in logo text).
#'   Default: basename of package_path
#' @param hex_color Character. Hex color for the logo background (default: "#2c5aa0")
#'
#' @return Invisibly returns the logo file path
#' @export
#' @examples
#' \dontrun{
#' create_package_logo("path/to/mypackage", "mypackage")
#' create_package_logo(".", "apaChecker", hex_color = "#e74c3c")
#' }
create_package_logo <- function(
    package_path,
    package_name = basename(normalizePath(package_path)),
    hex_color = "#2c5aa0"
) {

  # Create man/figures directory if it doesn't exist
  figures_dir <- file.path(package_path, "man", "figures")
  if (!dir.exists(figures_dir)) {
    dir.create(figures_dir, recursive = TRUE)
  }

  # Create SVG logo
  logo_path <- file.path(figures_dir, "logo.svg")

  # Extract initials from package name (max 3 characters)
  # Convert camelCase or snake_case to initials
  initials <- if (grepl("_", package_name)) {
    # snake_case: take first letter of each word
    parts <- strsplit(package_name, "_")[[1]]
    paste(toupper(substr(parts, 1, 1)), collapse = "")
  } else {
    # camelCase or single word: take capital letters or first letters
    capitals <- gregexpr("[A-Z]", package_name)[[1]]
    if (length(capitals) > 0 && capitals[1] != -1) {
      paste(substr(package_name, capitals, capitals), collapse = "")
    } else {
      toupper(substr(package_name, 1, min(3, nchar(package_name))))
    }
  }

  # Limit to 3 characters
  if (nchar(initials) > 3) {
    initials <- substr(initials, 1, 3)
  }

  # Helper function to adjust color brightness
  adjust_hex <- function(hex_color, factor = 0.7) {
    hex_color <- sub("^#", "", hex_color)
    r <- as.integer(paste0("0x", substr(hex_color, 1, 2)))
    g <- as.integer(paste0("0x", substr(hex_color, 3, 4)))
    b <- as.integer(paste0("0x", substr(hex_color, 5, 6)))
    r <- min(255, max(0, as.integer(r * factor)))
    g <- min(255, max(0, as.integer(g * factor)))
    b <- min(255, max(0, as.integer(b * factor)))
    sprintf("#%02x%02x%02x", r, g, b)
  }

  darker_color <- adjust_hex(hex_color, 0.7)

  # Create SVG content
  svg_content <- c(
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">',
    '  <!-- Hexagon background (standard R package shape) -->',
    '  <defs>',
    '    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">',
    paste0('      <stop offset="0%" style="stop-color:', hex_color, ';stop-opacity:1" />'),
    paste0('      <stop offset="100%" style="stop-color:', darker_color, ';stop-opacity:1" />'),
    '    </linearGradient>',
    '    <filter id="shadow">',
    '      <feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.3"/>',
    '    </filter>',
    '  </defs>',
    '  ',
    '  <!-- Hexagon -->',
    '  <path d="M 100,10 L 173,55 L 173,145 L 100,190 L 27,145 L 27,55 Z" ',
    '        fill="url(#bgGradient)" ',
    '        filter="url(#shadow)"/>',
    '  ',
    '  <!-- Package initials -->',
    '  <text x="100" y="115" ',
    '        font-family="Arial, sans-serif" ',
    '        font-size="60" ',
    '        font-weight="bold" ',
    '        fill="white" ',
    '        text-anchor="middle">',
    paste0('    ', initials),
    '  </text>',
    '  ',
    '  <!-- R logo indicator (optional small R) -->',
    '  <text x="100" y="165" ',
    '        font-family="Arial, sans-serif" ',
    '        font-size="16" ',
    '        font-weight="normal" ',
    '        fill="white" ',
    '        text-anchor="middle" ',
    '        opacity="0.8">',
    '    R Package',
    '  </text>',
    '</svg>'
  )

  writeLines(svg_content, logo_path)

  message("Logo created at: ", logo_path)
  message("\nTo use the logo in README.md, add this to the first line:")
  message(paste0('# ', package_name, ' <img src="man/figures/logo.svg" align="right" height="139" />'))
  message("\nTo create a PNG version (240x278px for pkgdown):")
  message("  library(magick)")
  message(paste0('  logo <- image_read_svg("', logo_path, '", width = 240)'))
  message(paste0('  image_write(logo, "', file.path(figures_dir, 'logo.png'), '")'))


  invisible(logo_path)
}
