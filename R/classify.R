#' Classify fluvial mesohabitats
#'
#' Main dispatcher for numeric values, tables, spatial vectors, and rasters.
#' All forms use the same lower-inclusive, upper-exclusive rule engine.
#'
#' @param x Numeric depth values, a table, a `SpatVector`, a `SpatRaster`, or a
#'   supported file path.
#' @param velocity Numeric velocity values or a velocity raster/path.
#' @param depth_col,velocity_col Table/vector column selectors.
#' @param ... Arguments passed to the type-specific classifier.
#' @return The corresponding classified data frame, `SpatVector`, or
#'   categorical `SpatRaster`.
#' @seealso [classify_mesohabitat_values()], [classify_mesohabitat_table()],
#'   [classify_mesohabitat_vector()], [classify_mesohabitat_raster()]
#' @examples
#' classify_mesohabitat(c(0.2, 0.8), c(0.1, 0.4))
#' @export
classify_mesohabitat <- function(x, velocity = NULL, depth_col = NULL,
                                 velocity_col = NULL, ...) {
  if (is.numeric(x)) return(classify_mesohabitat_values(x, velocity, ...))
  if (inherits(x, "SpatRaster")) {
    return(classify_mesohabitat_raster(x, velocity, ...))
  }
  if (inherits(x, "SpatVector")) {
    return(classify_mesohabitat_vector(x, depth_col, velocity_col, ...))
  }
  if (is.data.frame(x) || is.matrix(x)) {
    return(classify_mesohabitat_table(x, depth_col, velocity_col, ...))
  }
  if (is.character(x) && length(x) == 1L) {
    if (!file.exists(x)) stop("Input file does not exist: ", x, call. = FALSE)
    ext <- tolower(tools::file_ext(x))
    if (ext %in% c("csv", "txt", "tsv")) {
      return(classify_mesohabitat_table(x, depth_col, velocity_col, ...))
    }
    if (ext %in% c("tif", "tiff", "grd", "nc", "img", "vrt")) {
      return(classify_mesohabitat_raster(x, velocity, ...))
    }
    return(classify_mesohabitat_vector(x, depth_col, velocity_col, ...))
  }
  stop("Unsupported input type for `classify_mesohabitat()`.", call. = FALSE)
}

