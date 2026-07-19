.check_scheme <- function(scheme) {
  if (missing(scheme) || is.null(scheme)) scheme <- meso_scheme_default()
  validate_meso_scheme(scheme)
  scheme
}

.recycle_pair <- function(depth, velocity) {
  nd <- length(depth); nv <- length(velocity)
  if (nd == nv) return(list(depth = depth, velocity = velocity))
  if (nd == 1L && nv > 1L) return(list(depth = rep(depth, nv), velocity = velocity))
  if (nv == 1L && nd > 1L) return(list(depth = depth, velocity = rep(velocity, nd)))
  stop("`depth` and `velocity` must have equal lengths, or one must have length one.",
       call. = FALSE)
}

.classify_engine <- function(depth, velocity, scheme, invalid = c("error", "NA"),
                             dry_threshold = NULL) {
  invalid <- match.arg(invalid)
  if (!is.numeric(depth) || !is.numeric(velocity)) {
    stop("Depth and velocity must be numeric.", call. = FALSE)
  }
  pair <- .recycle_pair(depth, velocity)
  depth <- pair$depth; velocity <- pair$velocity
  bad <- (!is.na(depth) & (!is.finite(depth) | depth < 0)) |
    (!is.na(velocity) & (!is.finite(velocity) | velocity < 0))
  if (any(bad) && invalid == "error") {
    stop(sum(bad), " observation(s) have negative or non-finite depth/velocity; ",
         "use `invalid = \"NA\"` to return missing classifications.", call. = FALSE)
  }
  depth_work <- depth; velocity_work <- velocity
  depth_work[bad] <- NA_real_; velocity_work[bad] <- NA_real_
  out <- rep(NA_integer_, length(depth_work))
  valid <- !is.na(depth_work) & !is.na(velocity_work)
  dry <- rep(FALSE, length(out))
  if (!is.null(dry_threshold)) {
    if (!is.numeric(dry_threshold) || length(dry_threshold) != 1L ||
        is.na(dry_threshold) || !is.finite(dry_threshold) || dry_threshold < 0) {
      stop("`dry_threshold` must be NULL or one nonnegative finite number.",
           call. = FALSE)
    }
    dry <- valid & depth_work <= dry_threshold
    valid[dry] <- FALSE
  }
  rules <- scheme$rules
  matches <- integer(length(out))
  for (i in seq_len(nrow(rules))) {
    hit <- valid & depth_work >= rules$depth_min[i] &
      depth_work < rules$depth_max[i] &
      velocity_work >= rules$velocity_min[i] &
      velocity_work < rules$velocity_max[i]
    matches[hit] <- matches[hit] + 1L
    out[hit & is.na(out)] <- as.integer(rules$class_id[i])
  }
  if (any(matches > 1L)) {
    stop("Validated scheme produced ambiguous multiple matches.", call. = FALSE)
  }
  if (!scheme$allow_gaps && any(valid & matches == 0L)) {
    stop("Complete scheme failed to classify valid observations.", call. = FALSE)
  }
  out
}

.factor_from_ids <- function(ids, scheme) {
  factor(ids, levels = scheme$rules$class_id, labels = scheme$rules$label,
         ordered = FALSE)
}

#' Classify numeric depth and velocity values
#'
#' Applies one authoritative rule-table engine. Lower bounds are inclusive,
#' upper bounds are exclusive, missing inputs remain missing, and zero depth and
#' velocity are classified mathematically (Class 1 under the default scheme).
#'
#' @param depth,velocity Numeric vectors in the units declared by `scheme`.
#'   Length-one inputs may be deliberately recycled; other unequal lengths fail.
#' @param scheme A validated `meso_scheme`.
#' @param dry_threshold `NULL` to preserve the scheme exactly, or a nonnegative
#'   depth at or below which classifications become `NA`.
#' @param invalid Either `"error"` (default) or `"NA"` for negative and
#'   infinite observations. Values are never clamped or replaced with zero.
#' @return A data frame containing depth, velocity, integer
#'   `mesohabitat_class`, and unordered factor `mesohabitat`.
#' @references Cordero, E. and Harris, A. (2026). SSRN.
#'   \doi{10.2139/ssrn.7100727}.
#' @seealso [classify_mesohabitat()], [classify_mesohabitat_table()],
#'   [convert_hydraulic_units()]
#' @examples
#' classify_mesohabitat_values(c(0.2, 0.61, 1.37), c(0.1, 0.61, 0.3))
#' @export
classify_mesohabitat_values <- function(depth, velocity,
                                        scheme = meso_scheme_default(),
                                        dry_threshold = NULL,
                                        invalid = c("error", "NA")) {
  scheme <- .check_scheme(scheme)
  pair <- .recycle_pair(depth, velocity)
  ids <- .classify_engine(pair$depth, pair$velocity, scheme,
                          invalid = invalid, dry_threshold = dry_threshold)
  data.frame(
    depth = pair$depth,
    velocity = pair$velocity,
    mesohabitat_class = ids,
    mesohabitat = .factor_from_ids(ids, scheme),
    stringsAsFactors = FALSE
  )
}

