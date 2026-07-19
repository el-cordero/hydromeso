.as_rast <- function(x, arg) {
  if (inherits(x, "SpatRaster")) return(x)
  if (is.character(x) && length(x) == 1L && file.exists(x)) return(terra::rast(x))
  stop("`", arg, "` must be a `terra::SpatRaster` or raster file path.", call. = FALSE)
}

.pick_layer <- function(x, layer, arg) {
  if (is.null(layer)) {
    if (terra::nlyr(x) != 1L) {
      stop("`", arg, "` has multiple layers; select one explicitly.", call. = FALSE)
    }
    return(x)
  }
  if (length(layer) != 1L || is.na(layer)) stop("Layer selectors must have length one.", call. = FALSE)
  if (is.character(layer)) {
    if (!layer %in% names(x)) stop("Layer `", layer, "` was not found in `", arg, "`.", call. = FALSE)
    return(x[[layer]])
  }
  if (!is.numeric(layer) || layer != as.integer(layer) || layer < 1L || layer > terra::nlyr(x)) {
    stop("Invalid layer position for `", arg, "`.", call. = FALSE)
  }
  x[[as.integer(layer)]]
}

.has_crs <- function(x) nzchar(terra::crs(x, proj = TRUE))

.assign_assumed_crs <- function(x, assume_crs, arg) {
  if (!.has_crs(x) && !is.null(assume_crs)) {
    terra::crs(x) <- assume_crs
    message("Assigned `assume_crs` to ", arg,
            "; coordinates were not transformed.")
  }
  x
}

.align_velocity <- function(depth, velocity, align) {
  same <- isTRUE(terra::compareGeom(depth, velocity, stopOnError = FALSE))
  if (same) return(velocity)
  if (align == "error") {
    stop("Depth and velocity raster geometry differs. Use ",
         "`align = \"velocity_to_depth\"` to align velocity explicitly.", call. = FALSE)
  }
  if (!.has_crs(depth) || !.has_crs(velocity)) {
    stop("Raster alignment requires CRS information for both inputs.", call. = FALSE)
  }
  same_crs <- isTRUE(terra::same.crs(depth, velocity))
  if (same_crs) terra::resample(velocity, depth, method = "bilinear") else
    terra::project(velocity, depth, method = "bilinear")
}

.categorize_raster <- function(x, scheme) {
  names(x) <- "mesohabitat_class"
  levels(x) <- data.frame(
    value = as.integer(scheme$rules$class_id),
    mesohabitat = scheme$rules$label,
    stringsAsFactors = FALSE
  )
  x
}

.class_datatype <- function(scheme) {
  mx <- max(scheme$rules$class_id)
  if (mx <= 254L) "INT1U" else if (mx <= 65534L) "INT2U" else "INT4S"
}

#' Classify depth and velocity rasters
#'
#' Supports separate rasters or a selected pair in one multilayer raster. Depth
#' is always the geometry template. Continuous velocity is aligned only when
#' explicitly requested and always with bilinear interpolation.
#'
#' @param depth A `SpatRaster` or raster path. It may contain both selected
#'   layers when `velocity = NULL`.
#' @param velocity A separate `SpatRaster` or path, or `NULL`.
#' @param scheme A validated `meso_scheme`; values must use its units.
#' @param depth_layer,velocity_layer Optional layer names or positions.
#' @param align `"error"` or `"velocity_to_depth"`.
#' @param aoi Optional `SpatVector` or vector path.
#' @param mask_aoi If `TRUE`, crop and polygon-mask; otherwise rectangular crop.
#' @param assume_crs Optional CRS assigned only to inputs missing a CRS. This
#'   does not transform coordinates and emits a message.
#' @param dry_threshold,invalid Classification controls.
#' @param filename Optional output filename.
#' @param overwrite Permit overwriting `filename`.
#' @param ... Additional [terra::writeRaster()] options.
#' @return A categorical integer `SpatRaster` on the (possibly AOI-cropped)
#'   depth geometry, with a complete class table.
#' @seealso [classify_mesohabitat_series()], [write_mesohabitat()]
#' @examples
#' d <- terra::rast(nrows = 2, ncols = 4, xmin = 0, xmax = 4, ymin = 0, ymax = 2,
#'                  crs = "EPSG:32615", vals = c(0.2, 0.8, 1.5, 0.2, 0.2, 0.8, 0.8, 1.5))
#' v <- d
#' terra::values(v) <- c(0.1, 0.1, 0.1, 0.4, 0.8, 0.4, 0.8, 0.8)
#' classify_mesohabitat_raster(d, v)
#' @export
classify_mesohabitat_raster <- function(depth, velocity = NULL,
                                        scheme = meso_scheme_default(),
                                        depth_layer = NULL,
                                        velocity_layer = NULL,
                                        align = c("error", "velocity_to_depth"),
                                        aoi = NULL, mask_aoi = TRUE,
                                        assume_crs = NULL,
                                        dry_threshold = NULL,
                                        invalid = c("error", "NA"),
                                        filename = "", overwrite = FALSE, ...) {
  scheme <- .check_scheme(scheme)
  align <- match.arg(align); invalid <- match.arg(invalid)
  source <- .as_rast(depth, "depth")
  if (is.null(velocity)) {
    if (is.null(depth_layer) || is.null(velocity_layer)) {
      stop("Select `depth_layer` and `velocity_layer` for a combined raster.", call. = FALSE)
    }
    depth <- .pick_layer(source, depth_layer, "depth")
    velocity <- .pick_layer(source, velocity_layer, "depth")
  } else {
    depth <- .pick_layer(source, depth_layer, "depth")
    velocity <- .pick_layer(.as_rast(velocity, "velocity"), velocity_layer, "velocity")
  }
  depth <- .assign_assumed_crs(depth, assume_crs, "depth raster")
  velocity <- .assign_assumed_crs(velocity, assume_crs, "velocity raster")
  velocity <- .align_velocity(depth, velocity, align)
  if (!is.null(aoi)) {
    if (is.character(aoi) && length(aoi) == 1L) aoi <- terra::vect(aoi)
    if (!inherits(aoi, "SpatVector")) stop("`aoi` must be a SpatVector or vector path.", call. = FALSE)
    if (!.has_crs(depth) || !.has_crs(aoi)) stop("AOI use requires CRS information.", call. = FALSE)
    if (!isTRUE(terra::same.crs(depth, aoi))) aoi <- terra::project(aoi, terra::crs(depth))
    depth <- terra::crop(depth, aoi)
    velocity <- terra::crop(velocity, aoi)
    if (isTRUE(mask_aoi)) {
      depth <- terra::mask(depth, aoi)
      velocity <- terra::mask(velocity, aoi)
    }
  }
  mins <- terra::global(c(depth, velocity), "min", na.rm = TRUE)
  maxs <- terra::global(c(depth, velocity), "max", na.rm = TRUE)
  bad <- any(!is.na(mins[, 1]) & mins[, 1] < 0) ||
    any(!is.na(maxs[, 1]) & !is.finite(maxs[, 1]))
  if (bad && invalid == "error") {
    stop("Raster inputs contain negative or infinite hydraulic values; use ",
         "`invalid = \"NA\"` to make their classifications missing.", call. = FALSE)
  }
  fun <- function(d, v) .classify_engine(d, v, scheme, invalid, dry_threshold)
  args <- list(x = c(depth, velocity), fun = fun)
  out <- do.call(terra::lapp, args)
  out <- .categorize_raster(out, scheme)
  if (nzchar(filename)) {
    out <- terra::writeRaster(out, filename, overwrite = TRUE,
                              datatype = .class_datatype(scheme),
                              gdal = "COMPRESS=LZW", ...)
  }
  attr(out, "meso_scheme") <- scheme
  out
}
