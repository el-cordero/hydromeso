#' Classify spatial vector features from depth and velocity attributes
#'
#' Geometry, CRS, feature order, and existing attributes are retained. Points,
#' lines, and polygons are accepted because classification uses attributes.
#'
#' @param x A `terra::SpatVector` or vector dataset path supported by `terra`.
#' @param depth_col,velocity_col Attribute names or positions.
#' @param scheme,class_col,label_col,overwrite,dry_threshold,invalid As in
#'   [classify_mesohabitat_table()].
#' @param layer Optional layer name when reading a multi-layer vector dataset.
#' @param ... Additional arguments passed to [terra::vect()] for a path.
#' @return A `terra::SpatVector` with integer class and label attributes.
#' @seealso [classify_mesohabitat_raster()], [write_mesohabitat()]
#' @examples
#' x <- data.frame(x = 1:3, y = 1:3, depth = c(0.2, 0.8, 2),
#'                 velocity = c(0.1, 0.4, 0.7))
#' v <- terra::vect(x, geom = c("x", "y"), crs = "EPSG:32615")
#' classify_mesohabitat_vector(v, "depth", "velocity")
#' @export
classify_mesohabitat_vector <- function(x, depth_col, velocity_col,
                                        scheme = meso_scheme_default(),
                                        class_col = "mesohabitat_class",
                                        label_col = "mesohabitat",
                                        overwrite = FALSE,
                                        dry_threshold = NULL,
                                        invalid = c("error", "NA"),
                                        layer = NULL, ...) {
  if (is.character(x) && length(x) == 1L) {
    if (!file.exists(x)) stop("Vector file does not exist: ", x, call. = FALSE)
    if (is.null(layer)) x <- terra::vect(x, ...) else x <- terra::vect(x, layer = layer, ...)
  }
  if (!inherits(x, "SpatVector")) {
    stop("`x` must be a `terra::SpatVector` or supported vector path.", call. = FALSE)
  }
  attrs <- as.data.frame(x)
  dcol <- .resolve_column(attrs, depth_col, "depth_col")
  vcol <- .resolve_column(attrs, velocity_col, "velocity_col")
  .check_output_columns(names(attrs), class_col, label_col, overwrite)
  ans <- classify_mesohabitat_values(
    .safe_numeric(attrs[[dcol]], dcol), .safe_numeric(attrs[[vcol]], vcol),
    scheme, dry_threshold, invalid
  )
  x[[class_col]] <- ans$mesohabitat_class
  x[[label_col]] <- as.character(ans$mesohabitat)
  attr(x, "meso_scheme") <- scheme
  x
}
