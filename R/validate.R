.required_rule_columns <- c(
  "class_id", "label", "depth_min", "depth_max",
  "velocity_min", "velocity_max"
)

.axis_test_values <- function(bounds, lower = 0) {
  finite <- sort(unique(bounds[is.finite(bounds)]))
  finite <- finite[finite >= lower]
  points <- unique(c(lower, finite))
  if (length(finite)) {
    breaks <- sort(unique(c(lower, finite)))
    if (length(breaks) > 1L) {
      points <- c(points, (breaks[-length(breaks)] + breaks[-1L]) / 2)
    }
    top <- max(breaks)
    points <- c(points, top + max(1, abs(top) * 0.5))
  } else {
    points <- c(points, lower + 1)
  }
  sort(unique(points))
}

.rule_matches <- function(depth, velocity, rules) {
  vapply(seq_len(nrow(rules)), function(i) {
    depth >= rules$depth_min[i] && depth < rules$depth_max[i] &&
      velocity >= rules$velocity_min[i] && velocity < rules$velocity_max[i]
  }, logical(1))
}

.region_text <- function(d, v) {
  paste0("near depth ", format(d, digits = 8),
         " and velocity ", format(v, digits = 8))
}

#' Validate a mesohabitat classification scheme
#'
#' Performs deterministic breakpoint-based checks of rule structure, metadata,
#' overlaps, gaps, and reachability. The nonnegative depth-velocity plane is the
#' required domain unless gaps are allowed. No random sampling is used.
#'
#' @param x A `meso_scheme` object.
#' @return The validated object, invisibly.
#' @seealso [meso_scheme()]
#' @examples
#' validate_meso_scheme(meso_scheme_default())
#' @export
validate_meso_scheme <- function(x) {
  if (!inherits(x, "meso_scheme") || !is.list(x)) {
    stop("`x` must be a `meso_scheme` object.", call. = FALSE)
  }
  metadata <- c("name", "depth_units", "velocity_units", "boundary",
                "allow_gaps", "allow_negative", "complete_coverage_expected")
  missing_meta <- setdiff(metadata, names(x))
  if (length(missing_meta)) {
    stop("Scheme metadata are incomplete; missing: ",
         paste(missing_meta, collapse = ", "), ".", call. = FALSE)
  }
  for (nm in c("name", "depth_units", "velocity_units", "boundary")) {
    if (!is.character(x[[nm]]) || length(x[[nm]]) != 1L ||
        is.na(x[[nm]]) || !nzchar(trimws(x[[nm]]))) {
      stop("Scheme metadata `", nm, "` must be one nonempty string.",
           call. = FALSE)
    }
  }
  if (!identical(x$boundary,
                 "lower bounds inclusive; upper bounds exclusive")) {
    stop("Scheme boundary metadata are inconsistent with package rules.",
         call. = FALSE)
  }
  if (!is.logical(x$allow_gaps) || length(x$allow_gaps) != 1L ||
      is.na(x$allow_gaps) || !is.logical(x$allow_negative) ||
      length(x$allow_negative) != 1L || is.na(x$allow_negative)) {
    stop("`allow_gaps` and `allow_negative` metadata must be single logical values.",
         call. = FALSE)
  }
  if (!identical(x$complete_coverage_expected, !x$allow_gaps)) {
    stop("Coverage metadata are inconsistent with `allow_gaps`.", call. = FALSE)
  }
  rules <- x$rules
  if (!is.data.frame(rules)) {
    stop("Scheme `rules` must be a data frame.", call. = FALSE)
  }
  missing_cols <- setdiff(.required_rule_columns, names(rules))
  if (length(missing_cols)) {
    stop("Rule table is missing required columns: ",
         paste(missing_cols, collapse = ", "), ".", call. = FALSE)
  }
  if (!nrow(rules)) stop("Rule table must contain at least one rule.", call. = FALSE)
  ids <- rules$class_id
  if (!is.numeric(ids) || anyNA(ids) || any(!is.finite(ids)) ||
      any(ids <= 0) || any(ids != as.integer(ids))) {
    stop("`class_id` must contain positive finite integers.", call. = FALSE)
  }
  if (anyDuplicated(ids)) {
    stop("Duplicated class IDs: ",
         paste(unique(ids[duplicated(ids)]), collapse = ", "), ".", call. = FALSE)
  }
  labels <- rules$label
  if (!is.character(labels) || anyNA(labels) || any(!nzchar(trimws(labels)))) {
    stop("`label` must contain nonempty character values.", call. = FALSE)
  }
  if (anyDuplicated(labels)) {
    stop("Duplicated labels: ",
         paste(unique(labels[duplicated(labels)]), collapse = ", "), ".",
         call. = FALSE)
  }
  bound_names <- c("depth_min", "depth_max", "velocity_min", "velocity_max")
  for (nm in bound_names) {
    z <- rules[[nm]]
    if (!is.numeric(z)) stop("`", nm, "` must be numeric.", call. = FALSE)
    if (anyNA(z) || any(is.nan(z))) {
      stop("Missing rule bounds are not permitted in `", nm, "`.", call. = FALSE)
    }
  }
  if (any(is.infinite(rules$depth_min)) || any(is.infinite(rules$velocity_min)) ||
      any(rules$depth_max == -Inf) || any(rules$velocity_max == -Inf)) {
    stop("Infinite values are permitted only as positive upper bounds.", call. = FALSE)
  }
  bad_width <- rules$depth_min >= rules$depth_max |
    rules$velocity_min >= rules$velocity_max
  if (any(bad_width)) {
    stop("Rule minima must be less than maxima; invalid class IDs: ",
         paste(rules$class_id[bad_width], collapse = ", "), ".", call. = FALSE)
  }
  if (!x$allow_negative &&
      any(rules$depth_min < 0 | rules$velocity_min < 0)) {
    stop("Negative lower bounds require `allow_negative = TRUE`.", call. = FALSE)
  }

  if (nrow(rules) > 1L) {
    pairs <- utils::combn(seq_len(nrow(rules)), 2L)
    for (j in seq_len(ncol(pairs))) {
      a <- pairs[1L, j]; b <- pairs[2L, j]
      d_overlap <- max(rules$depth_min[c(a, b)]) <
        min(rules$depth_max[c(a, b)])
      v_overlap <- max(rules$velocity_min[c(a, b)]) <
        min(rules$velocity_max[c(a, b)])
      if (d_overlap && v_overlap) {
        stop("Overlapping classes ", rules$class_id[a], " ('", rules$label[a],
             "') and ", rules$class_id[b], " ('", rules$label[b],
             "') near depth ", max(rules$depth_min[c(a, b)]),
             " and velocity ", max(rules$velocity_min[c(a, b)]), ".",
             call. = FALSE)
      }
    }
  }

  lower <- if (x$allow_negative) {
    min(c(rules$depth_min, rules$velocity_min, 0))
  } else 0
  ds <- .axis_test_values(c(rules$depth_min, rules$depth_max), lower)
  vs <- .axis_test_values(c(rules$velocity_min, rules$velocity_max), lower)
  reached <- rep(FALSE, nrow(rules))
  first_gap <- NULL
  for (d in ds) for (v in vs) {
    matched <- .rule_matches(d, v, rules)
    if (sum(matched) > 1L) {
      stop("Multiple rules match ", .region_text(d, v), ": class IDs ",
           paste(rules$class_id[matched], collapse = ", "), ".", call. = FALSE)
    }
    reached <- reached | matched
    if (!any(matched) && is.null(first_gap)) first_gap <- c(d, v)
  }
  if (any(!reached)) {
    stop("Unreachable rules detected for class IDs: ",
         paste(rules$class_id[!reached], collapse = ", "), ".", call. = FALSE)
  }
  if (!x$allow_gaps && !is.null(first_gap)) {
    stop("Uncovered depth-velocity region ",
         .region_text(first_gap[1L], first_gap[2L]),
         ". Set `allow_gaps = TRUE` only when gaps are intentional.", call. = FALSE)
  }
  invisible(x)
}

