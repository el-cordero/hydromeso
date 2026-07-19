.scheme_from_object <- function(x, class_col = "mesohabitat_class",
                                label_col = "mesohabitat") {
  scheme <- attr(x, "meso_scheme")
  if (inherits(scheme, "meso_scheme")) return(scheme)
  meso_scheme_default()
}

.summary_records <- function(ids, labels, scheme) {
  valid <- !is.na(ids); nvalid <- sum(valid); missing <- sum(!valid)
  counts <- tabulate(match(ids[valid], scheme$rules$class_id), nbins = nrow(scheme$rules))
  data.frame(
    class_id = as.integer(scheme$rules$class_id), label = scheme$rules$label,
    record_count = as.integer(counts),
    percentage = if (nvalid) 100 * counts / nvalid else NA_real_,
    missing_count = missing, stringsAsFactors = FALSE
  )
}

.raster_summary_layer <- function(x, scenario, scheme, denominator, analysis_mask) {
  raw <- x
  levels(raw) <- NULL
  area <- terra::cellSize(raw, unit = "m", mask = TRUE)
  z <- terra::zonal(area, raw, fun = "sum", na.rm = TRUE)
  f <- terra::zonal(terra::init(raw, 1), raw, fun = "sum", na.rm = TRUE)
  ids <- scheme$rules$class_id
  areas <- stats::setNames(rep(0, length(ids)), ids)
  counts <- stats::setNames(rep(0L, length(ids)), ids)
  if (!is.null(z) && nrow(z)) {
    zi <- match(as.integer(z[, 1]), ids)
    areas[zi[!is.na(zi)]] <- z[!is.na(zi), 2]
  }
  if (!is.null(f) && nrow(f)) {
    fi <- match(as.integer(f[, 1]), ids)
    counts[fi[!is.na(fi)]] <- as.integer(f[!is.na(fi), 2])
  }
  denom <- if (denominator == "mask") {
    if (is.null(analysis_mask)) stop("`analysis_mask` is required for denominator = \"mask\".", call. = FALSE)
    m <- .as_rast(analysis_mask, "analysis_mask")
    if (!isTRUE(terra::compareGeom(x, m, stopOnError = FALSE))) stop("Analysis mask geometry differs.", call. = FALSE)
    as.numeric(terra::global(terra::cellSize(m, unit = "m", mask = TRUE), "sum", na.rm = TRUE)[1, 1])
  } else sum(areas)
  data.frame(
    scenario = scenario, class_id = as.integer(ids), label = scheme$rules$label,
    cell_count = as.integer(counts), area_m2 = as.numeric(areas),
    hectares = as.numeric(areas) / 10000, square_kilometres = as.numeric(areas) / 1e6,
    acres = as.numeric(areas) / 4046.8564224,
    percentage = if (denom > 0) 100 * as.numeric(areas) / denom else NA_real_,
    stringsAsFactors = FALSE
  )
}

#' Summarize mesohabitat classes
#'
#' Summarizes classified tables, vectors, rasters, and raster scenarios. Raster
#' areas use [terra::cellSize()] and are valid for projected or geographic grids.
#'
#' @param x A classified data frame, `SpatVector`, or `SpatRaster`.
#' @param class_col,label_col Classification field names for tables/vectors.
#' @param denominator Raster percentage denominator: `"classified"`,
#'   `"non_na"`, or `"mask"`. The first two are equivalent for a classified
#'   raster; `"mask"` uses `analysis_mask` area.
#' @param analysis_mask Optional raster mask.
#' @return An ordinary data frame.
#' @seealso [compare_mesohabitat()]
#' @export
summarize_mesohabitat <- function(x, class_col = "mesohabitat_class",
                                  label_col = "mesohabitat",
                                  denominator = c("classified", "non_na", "mask"),
                                  analysis_mask = NULL) {
  denominator <- match.arg(denominator); scheme <- .scheme_from_object(x)
  if (is.data.frame(x)) {
    if (!all(c(class_col, label_col) %in% names(x))) stop("Classification columns were not found.", call. = FALSE)
    return(.summary_records(x[[class_col]], x[[label_col]], scheme))
  }
  if (inherits(x, "SpatVector")) {
    a <- as.data.frame(x)
    if (!all(c(class_col, label_col) %in% names(a))) stop("Classification attributes were not found.", call. = FALSE)
    type <- tolower(terra::geomtype(x))
    base <- .summary_records(a[[class_col]], a[[label_col]], scheme)
    if (grepl("polygon", type)) {
      measure <- terra::expanse(x, unit = "m")
      sums <- tapply(measure[!is.na(a[[class_col]])], a[[class_col]][!is.na(a[[class_col]])], sum)
      base$area_m2 <- as.numeric(sums[match(base$class_id, as.integer(names(sums)))])
      base$area_m2[is.na(base$area_m2)] <- 0
      base$percentage_area <- if (sum(base$area_m2)) 100 * base$area_m2 / sum(base$area_m2) else NA_real_
    } else if (grepl("line", type)) {
      measure <- terra::perim(x)
      sums <- tapply(measure[!is.na(a[[class_col]])], a[[class_col]][!is.na(a[[class_col]])], sum)
      base$length_m <- as.numeric(sums[match(base$class_id, as.integer(names(sums)))])
      base$length_m[is.na(base$length_m)] <- 0
      base$percentage_length <- if (sum(base$length_m)) 100 * base$length_m / sum(base$length_m) else NA_real_
    }
    return(base)
  }
  if (inherits(x, "SpatRaster")) {
    out <- lapply(seq_len(terra::nlyr(x)), function(i) {
      .raster_summary_layer(x[[i]], names(x)[i], scheme, denominator, analysis_mask)
    })
    return(do.call(rbind, out))
  }
  stop("Unsupported object type for summarization.", call. = FALSE)
}
