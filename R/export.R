.prepare_output_path <- function(path, overwrite, create_dir) {
  if (!is.character(path) || length(path) != 1L || !nzchar(path)) stop("`filename` must be one path.", call. = FALSE)
  parent <- dirname(path)
  if (!dir.exists(parent)) {
    if (!isTRUE(create_dir)) stop("Parent directory does not exist; set `create_dir = TRUE`.", call. = FALSE)
    dir.create(parent, recursive = TRUE, showWarnings = FALSE)
  }
  if (file.exists(path) && !overwrite) stop("Output exists and `overwrite = FALSE`: ", path, call. = FALSE)
  file.path(normalizePath(parent, mustWork = TRUE), basename(path))
}

.write_sidecar <- function(path, scheme, overwrite) {
  side <- paste0(tools::file_path_sans_ext(path), "_classes.csv")
  if (file.exists(side) && !overwrite) stop("Class-table sidecar already exists: ", side, call. = FALSE)
  utils::write.csv(scheme$rules, side, row.names = FALSE)
  side
}

#' Write classified mesohabitat output
#'
#' Dispatches to a categorical GeoTIFF or other raster format, a `terra` vector
#' format, or CSV. Shapefile output uses short safe class field names to avoid
#' silent truncation.
#'
#' @param x A classified data frame, `SpatVector`, or `SpatRaster`.
#' @param filename Output path.
#' @param overwrite Permit replacement.
#' @param sidecar Write a CSV class table beside the output.
#' @param create_dir Create missing parent directories only when `TRUE`.
#' @param scheme A `meso_scheme` used for the sidecar.
#' @param ... Format-specific writer arguments.
#' @return The normalized output path, invisibly.
#' @export
write_mesohabitat <- function(x, filename, overwrite = FALSE, sidecar = TRUE,
                              create_dir = FALSE,
                              scheme = .scheme_from_object(x), ...) {
  path <- .prepare_output_path(filename, overwrite, create_dir)
  if (inherits(x, "SpatRaster")) {
    terra::writeRaster(x, path, overwrite = overwrite,
                       datatype = .class_datatype(scheme),
                       gdal = "COMPRESS=LZW", ...)
  } else if (inherits(x, "SpatVector")) {
    if (tolower(tools::file_ext(path)) == "shp") {
      warning("Shapefile field names are limited; class fields are written as `meso_cls` and `mesohab`.", call. = FALSE)
      nms <- names(x); nms[nms == "mesohabitat_class"] <- "meso_cls"; nms[nms == "mesohabitat"] <- "mesohab"
      names(x) <- nms
    }
    terra::writeVector(x, path, overwrite = overwrite, ...)
  } else if (is.data.frame(x)) {
    utils::write.csv(x, path, row.names = FALSE, ...)
  } else stop("Unsupported object type for export.", call. = FALSE)
  path <- normalizePath(path, mustWork = TRUE)
  if (isTRUE(sidecar)) .write_sidecar(path, scheme, overwrite)
  invisible(path)
}
