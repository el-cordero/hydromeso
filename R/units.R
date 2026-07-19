#' Convert hydraulic depth and velocity units
#'
#' Explicitly converts values before classification. The default scheme remains
#' defined at exactly 0.61 and 1.37 m and 0.30 and 0.61 m/s; converted imperial
#' values can differ slightly at rounded published boundaries.
#'
#' @param depth,velocity Optional numeric values.
#' @param depth_from,depth_to One of `"m"`, `"cm"`, or `"ft"`.
#' @param velocity_from,velocity_to One of `"m/s"`, `"cm/s"`, or `"ft/s"`.
#' @return A list with converted `depth` and `velocity`.
#' @examples
#' convert_hydraulic_units(depth = 2, velocity = 1,
#'                         depth_from = "ft", velocity_from = "ft/s")
#' @export
convert_hydraulic_units <- function(depth = NULL, velocity = NULL,
                                    depth_from = "m", depth_to = "m",
                                    velocity_from = "m/s", velocity_to = "m/s") {
  df <- c(m = 1, cm = 0.01, ft = 0.3048)
  vf <- c("m/s" = 1, "cm/s" = 0.01, "ft/s" = 0.3048)
  if (!depth_from %in% names(df) || !depth_to %in% names(df)) {
    stop("Depth units must be one of: m, cm, ft.", call. = FALSE)
  }
  if (!velocity_from %in% names(vf) || !velocity_to %in% names(vf)) {
    stop("Velocity units must be one of: m/s, cm/s, ft/s.", call. = FALSE)
  }
  if (!is.null(depth) && !is.numeric(depth)) stop("`depth` must be numeric or NULL.", call. = FALSE)
  if (!is.null(velocity) && !is.numeric(velocity)) stop("`velocity` must be numeric or NULL.", call. = FALSE)
  list(
    depth = if (is.null(depth)) NULL else depth * unname(df[depth_from] / df[depth_to]),
    velocity = if (is.null(velocity)) NULL else velocity * unname(vf[velocity_from] / vf[velocity_to])
  )
}

