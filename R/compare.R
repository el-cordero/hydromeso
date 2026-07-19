#' Compare two classified mesohabitat rasters
#'
#' Reports nominal transitions, gains and losses by class, unchanged area, and
#' percentage changed. Numeric differences between IDs are never interpreted.
#'
#' @param before,after Single-layer classified `SpatRaster` objects.
#' @param align `"error"` (default) or `"after_to_before"`; explicit alignment
#'   uses nearest-neighbor resampling because class values are categorical.
#' @return A list of ordinary data frames and scalar area metrics.
#' @seealso [summarize_mesohabitat()]
#' @export
compare_mesohabitat <- function(before, after,
                                align = c("error", "after_to_before")) {
  before <- .pick_layer(.as_rast(before, "before"), NULL, "before")
  after <- .pick_layer(.as_rast(after, "after"), NULL, "after")
  align <- match.arg(align)
  if (!isTRUE(terra::compareGeom(before, after, stopOnError = FALSE))) {
    if (align == "error") stop("Classified raster geometries differ.", call. = FALSE)
    if (!.has_crs(before) || !.has_crs(after)) stop("Alignment requires both CRSs.", call. = FALSE)
    after <- if (isTRUE(terra::same.crs(before, after)))
      terra::resample(after, before, method = "near") else
      terra::project(after, before, method = "near")
  }
  levels(before) <- NULL
  levels(after) <- NULL
  pair <- c(before, after); names(pair) <- c("before", "after")
  ok <- !is.na(before) & !is.na(after)
  code <- terra::ifel(ok, before * 100000L + after, NA)
  freq <- terra::zonal(terra::init(code, 1), code, "sum", na.rm = TRUE)
  if (is.null(freq)) freq <- data.frame(value = integer(), count = integer()) else
    names(freq) <- c("value", "count")
  transitions <- data.frame(
    from_class = as.integer(freq$value %/% 100000L),
    to_class = as.integer(freq$value %% 100000L),
    cell_count = as.integer(freq$count)
  )
  cell_area <- terra::cellSize(before, unit = "m", mask = FALSE)
  area_code <- terra::zonal(cell_area, code, "sum", na.rm = TRUE)
  transitions$area_m2 <- if (nrow(transitions)) area_code[match(freq$value, area_code[, 1]), 2] else numeric()
  transitions$area_m2[is.na(transitions$area_m2)] <- 0
  ids <- sort(unique(c(transitions$from_class, transitions$to_class)))
  gains <- vapply(ids, function(id) sum(transitions$area_m2[transitions$to_class == id & transitions$from_class != id]), numeric(1))
  losses <- vapply(ids, function(id) sum(transitions$area_m2[transitions$from_class == id & transitions$to_class != id]), numeric(1))
  unchanged <- sum(transitions$area_m2[transitions$from_class == transitions$to_class])
  total <- sum(transitions$area_m2, na.rm = TRUE); changed <- total - unchanged
  list(
    transitions = transitions,
    gains = data.frame(class_id = ids, area_m2 = gains),
    losses = data.frame(class_id = ids, area_m2 = losses),
    unchanged_area_m2 = unchanged,
    percentage_changed = if (total > 0) 100 * changed / total else NA_real_
  )
}
