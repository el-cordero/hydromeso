.resolve_column <- function(x, col, arg) {
  if (length(col) != 1L || is.na(col)) {
    stop("`", arg, "` must select exactly one column.", call. = FALSE)
  }
  if (is.numeric(col)) {
    if (col != as.integer(col) || col < 1L || col > ncol(x)) {
      stop("`", arg, "` is outside the table's column range.", call. = FALSE)
    }
    return(names(x)[as.integer(col)])
  }
  if (!is.character(col) || !col %in% names(x)) {
    stop("`", arg, "` does not identify a table column.", call. = FALSE)
  }
  col
}

.safe_numeric <- function(z, field) {
  if (is.numeric(z)) return(as.numeric(z))
  if (is.factor(z)) z <- as.character(z)
  if (!is.character(z)) {
    stop("Field `", field, "` is not numeric or safely coercible.", call. = FALSE)
  }
  out <- suppressWarnings(as.numeric(z))
  failed <- !is.na(z) & nzchar(trimws(z)) & is.na(out)
  if (any(failed)) {
    stop(sum(failed), " value(s) in field `", field,
         "` could not be converted to numeric.", call. = FALSE)
  }
  out
}

.check_output_columns <- function(nms, class_col, label_col, overwrite) {
  if (!is.character(class_col) || length(class_col) != 1L ||
      !nzchar(class_col) || !is.character(label_col) ||
      length(label_col) != 1L || !nzchar(label_col) || class_col == label_col) {
    stop("Output column names must be distinct nonempty strings.", call. = FALSE)
  }
  collisions <- intersect(c(class_col, label_col), nms)
  if (length(collisions) && !overwrite) {
    stop("Output column(s) already exist: ", paste(collisions, collapse = ", "),
         ". Set `overwrite = TRUE` to replace them.", call. = FALSE)
  }
}

#' Classify a table of depth and velocity observations
#'
#' @param x A data frame, matrix, or path to a CSV file.
#' @param depth_col,velocity_col Column names or one-based positions.
#' @param scheme A validated `meso_scheme`.
#' @param class_col,label_col Names for appended output fields.
#' @param keep_input Keep all input columns; if `FALSE`, return selected inputs
#'   and classifications only.
#' @param overwrite Permit replacing existing output columns.
#' @param dry_threshold,invalid Passed to [classify_mesohabitat_values()].
#' @param ... Additional arguments passed to [utils::read.csv()] for a path.
#' @return A data frame in the original row order.
#' @seealso [classify_mesohabitat_vector()], [write_mesohabitat()]
#' @examples
#' x <- data.frame(site = letters[1:3], d = c(0.2, 0.8, 2), v = c(0.1, 0.4, 0.7))
#' classify_mesohabitat_table(x, "d", "v")
#' @export
classify_mesohabitat_table <- function(x, depth_col, velocity_col,
                                       scheme = meso_scheme_default(),
                                       class_col = "mesohabitat_class",
                                       label_col = "mesohabitat",
                                       keep_input = TRUE,
                                       overwrite = FALSE,
                                       dry_threshold = NULL,
                                       invalid = c("error", "NA"), ...) {
  if (is.character(x) && length(x) == 1L) {
    if (!file.exists(x)) stop("Table file does not exist: ", x, call. = FALSE)
    ext <- tolower(tools::file_ext(x))
    dots <- list(...)
    if (ext == "tsv" && !"sep" %in% names(dots)) dots$sep <- "\t"
    if (ext == "csv" && !"sep" %in% names(dots)) dots$sep <- ","
    x <- do.call(utils::read.table,
                 c(list(file = x, header = TRUE, check.names = FALSE,
                        stringsAsFactors = FALSE), dots))
  } else if (is.matrix(x)) {
    x <- as.data.frame(x, stringsAsFactors = FALSE)
  }
  if (!is.data.frame(x)) stop("`x` must be a data frame, matrix, or CSV path.", call. = FALSE)
  dcol <- .resolve_column(x, depth_col, "depth_col")
  vcol <- .resolve_column(x, velocity_col, "velocity_col")
  .check_output_columns(names(x), class_col, label_col, overwrite)
  depth <- .safe_numeric(x[[dcol]], dcol)
  velocity <- .safe_numeric(x[[vcol]], vcol)
  ans <- classify_mesohabitat_values(depth, velocity, scheme,
                                     dry_threshold, invalid)
  out <- if (isTRUE(keep_input)) x else x[c(dcol, vcol)]
  out[[class_col]] <- ans$mesohabitat_class
  out[[label_col]] <- ans$mesohabitat
  attr(out, "meso_scheme") <- scheme
  out
}
