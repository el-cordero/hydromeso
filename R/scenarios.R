.raster_scenarios <- function(x, arg) {
  if (inherits(x, "SpatRaster")) {
    out <- lapply(seq_len(terra::nlyr(x)), function(i) x[[i]])
    names(out) <- names(x)
    return(out)
  }
  if (!is.list(x) || !length(x)) {
    stop("`", arg, "` must be a multilayer raster or nonempty list.", call. = FALSE)
  }
  lapply(x, .as_rast, arg = arg)
}

.scenario_names <- function(x, arg) {
  nms <- names(x)
  if (is.null(nms) || anyNA(nms) || any(!nzchar(nms))) return(NULL)
  if (anyDuplicated(nms)) stop("Duplicated ", arg, " scenario names are not allowed.", call. = FALSE)
  nms
}

.pair_scenarios <- function(depth, velocity, positional) {
  dn <- .scenario_names(depth, "depth")
  vn <- .scenario_names(velocity, "velocity")
  if (!is.null(dn) && !is.null(vn)) {
    if (!setequal(dn, vn)) {
      stop("Depth and velocity scenario names do not match.", call. = FALSE)
    }
    return(list(depth = depth[dn], velocity = velocity[dn], names = dn))
  }
  if (!isTRUE(positional)) {
    stop("Scenario names are required for safe pairing; set `positional = TRUE` ",
         "to explicitly pair by position.", call. = FALSE)
  }
  if (length(depth) != length(velocity)) {
    stop("Positional pairing requires equal scenario counts.", call. = FALSE)
  }
  nms <- dn %||% vn %||% paste0("scenario_", seq_along(depth))
  list(depth = depth, velocity = velocity, names = nms)
}

`%||%` <- function(x, y) if (is.null(x)) y else x

#' Classify paired hydraulic raster scenarios
#'
#' Named scenarios are paired by unique names. Unnamed inputs are rejected
#' unless positional pairing is explicitly requested.
#'
#' @param depth,velocity Multilayer `SpatRaster` objects, lists of rasters, or
#'   lists of raster paths.
#' @param scenario_names Optional unique names that explicitly define both lists.
#' @param positional Permit explicit position-based pairing when names are absent.
#' @param scheme A `meso_scheme`.
#' @param ... Passed to [classify_mesohabitat_raster()].
#' @return A categorical multilayer `SpatRaster`, one layer per scenario.
#' @seealso [mesohabitat_from_median_hydraulics()], [modal_mesohabitat()]
#' @examples
#' d <- terra::rast(nrows = 1, ncols = 2, vals = c(0.2, 0.8), crs = "EPSG:32615")
#' v <- terra::rast(d); terra::values(v) <- c(0.1, 0.4)
#' classify_mesohabitat_series(list(low = d), list(low = v))
#' @export
classify_mesohabitat_series <- function(depth, velocity, scenario_names = NULL,
                                        positional = FALSE,
                                        scheme = meso_scheme_default(), ...) {
  dl <- .raster_scenarios(depth, "depth")
  vl <- .raster_scenarios(velocity, "velocity")
  if (!is.null(scenario_names)) {
    if (!is.character(scenario_names) || length(scenario_names) != length(dl) ||
        length(scenario_names) != length(vl) || anyNA(scenario_names) ||
        any(!nzchar(scenario_names)) || anyDuplicated(scenario_names)) {
      stop("`scenario_names` must be unique nonempty names for every pair.", call. = FALSE)
    }
    names(dl) <- names(vl) <- scenario_names
  }
  paired <- .pair_scenarios(dl, vl, positional)
  out <- lapply(seq_along(paired$names), function(i) {
    classify_mesohabitat_raster(paired$depth[[i]], paired$velocity[[i]],
                                scheme = scheme, ...)
  })
  result <- do.call(c, out)
  names(result) <- paired$names
  attr(result, "meso_scheme") <- scheme
  result
}

#' Mesohabitat derived from median hydraulic surfaces
#'
#' Calculates cellwise median depth and median velocity, then classifies those
#' hydraulic surfaces. This is not a numeric median of nominal class IDs and
#' should not be called "median mesohabitat".
#'
#' @param depth,velocity Multilayer `SpatRaster` objects or scenario lists.
#' @param na.rm Remove missing values in the cellwise medians.
#' @param scheme A `meso_scheme`.
#' @param ... Passed to [classify_mesohabitat_raster()].
#' @return A named list containing `median_depth`, `median_velocity`, and
#'   `mesohabitat_from_median_hydraulics`.
#' @seealso [classify_mesohabitat_series()], [modal_mesohabitat()]
#' @export
mesohabitat_from_median_hydraulics <- function(depth, velocity, na.rm = TRUE,
                                               scheme = meso_scheme_default(), ...) {
  dl <- .raster_scenarios(depth, "depth"); vl <- .raster_scenarios(velocity, "velocity")
  paired <- .pair_scenarios(dl, vl, positional = TRUE)
  ds <- Reduce(function(a, b) c(a, b), paired$depth)
  vs <- Reduce(function(a, b) c(a, b), paired$velocity)
  if (!isTRUE(terra::compareGeom(ds, vs, stopOnError = FALSE))) {
    stop("All median-hydraulics inputs must share geometry.", call. = FALSE)
  }
  md <- terra::app(ds, stats::median, na.rm = na.rm); names(md) <- "median_depth"
  mv <- terra::app(vs, stats::median, na.rm = na.rm); names(mv) <- "median_velocity"
  cls <- classify_mesohabitat_raster(md, mv, scheme = scheme, ...)
  names(cls) <- "mesohabitat_from_median_hydraulics"
  list(median_depth = md, median_velocity = mv,
       mesohabitat_from_median_hydraulics = cls)
}

#' Modal mesohabitat across scenarios
#'
#' Computes the most frequent nominal class per cell. It never calculates a
#' numeric median of class IDs.
#'
#' @param x A classified multilayer `SpatRaster`.
#' @param ties `"NA"` (default) or `"lowest_class"`.
#' @param na.rm Ignore missing scenarios.
#' @return A single categorical `SpatRaster`.
#' @export
modal_mesohabitat <- function(x, ties = c("NA", "lowest_class"), na.rm = TRUE) {
  if (!inherits(x, "SpatRaster") || terra::nlyr(x) < 1L) stop("`x` must be a SpatRaster.", call. = FALSE)
  ties <- match.arg(ties)
  fun <- function(v) {
    if (na.rm) v <- v[!is.na(v)]
    if (!length(v) || anyNA(v)) return(NA_integer_)
    tab <- table(v); winners <- as.integer(names(tab)[tab == max(tab)])
    if (length(winners) > 1L && ties == "NA") NA_integer_ else min(winners)
  }
  raw <- x
  levels(raw) <- NULL
  out <- terra::app(raw, fun)
  scheme <- attr(x, "meso_scheme") %||% meso_scheme_default()
  out <- .categorize_raster(out, scheme); names(out) <- "modal_mesohabitat"
  attr(out, "meso_scheme") <- scheme
  out
}
