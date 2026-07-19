#' Construct a mesohabitat classification scheme
#'
#' Creates and validates a rectangular classification in depth-velocity space.
#' Every lower bound is inclusive and every upper bound is exclusive. Class IDs
#' are nominal identifiers, not ecological ranks.
#'
#' @param rules A data frame with `class_id`, `label`, `depth_min`, `depth_max`,
#'   `velocity_min`, and `velocity_max`.
#' @param name Nonempty scheme name.
#' @param description Optional description.
#' @param depth_units,velocity_units Nonempty unit labels.
#' @param citation Optional source citation.
#' @param source_doi Optional source DOI.
#' @param allow_gaps Whether uncovered regions at nonnegative depth and velocity
#'   are permitted.
#' @param allow_negative Whether negative rule minima are permitted.
#' @return An object of class `meso_scheme`.
#' @seealso [validate_meso_scheme()], [meso_scheme_default()],
#'   [classify_mesohabitat_values()]
#' @examples
#' rules <- data.frame(
#'   class_id = c(1L, 2L), label = c("Slow", "Fast"),
#'   depth_min = c(0, 0), depth_max = c(Inf, Inf),
#'   velocity_min = c(0, 0.5), velocity_max = c(0.5, Inf)
#' )
#' meso_scheme(rules, name = "Two velocity classes")
#' @export
meso_scheme <- function(rules,
                        name = "Custom mesohabitat scheme",
                        description = NULL,
                        depth_units = "m",
                        velocity_units = "m/s",
                        citation = NULL,
                        source_doi = NULL,
                        allow_gaps = FALSE,
                        allow_negative = FALSE) {
  x <- list(
    rules = as.data.frame(rules, stringsAsFactors = FALSE),
    name = name,
    description = description,
    depth_units = depth_units,
    velocity_units = velocity_units,
    boundary = "lower bounds inclusive; upper bounds exclusive",
    citation = citation,
    source_doi = source_doi,
    allow_gaps = allow_gaps,
    allow_negative = allow_negative,
    complete_coverage_expected = !allow_gaps
  )
  class(x) <- "meso_scheme"
  validate_meso_scheme(x)
}

#' Default eight-class fluvial mesohabitat scheme
#'
#' Returns the exact depth-velocity classification used by Cordero and Harris
#' (2026). The broader depth-velocity framework is informed by Aadland (1993),
#' whose paper describes six habitat types and should not be read as the source
#' of the two added high-velocity class names. Inputs must be metres and metres
#' per second unless explicitly converted before classification.
#'
#' @return A validated `meso_scheme` with eight nominal classes.
#' @references
#' Cordero, E. and Harris, A. (2026). *Semi-Supervised and Supervised Machine
#' Learning Approaches to Predicting Fluvial Mesohabitats from Satellite Data*.
#' SSRN. \doi{10.2139/ssrn.7100727}.
#'
#' Aadland, L. P. (1993). Stream Habitat Types: Their Fish Assemblages and
#' Relationship to Flow. *North American Journal of Fisheries Management*,
#' 13, 790-806. \doi{10.1577/1548-8675(1993)013<0790:SHTTFA>2.3.CO;2}.
#' @seealso [meso_scheme()], [plot_meso_scheme()]
#' @examples
#' meso_scheme_default()
#' @export
meso_scheme_default <- function() {
  rules <- data.frame(
    class_id = 1:8,
    label = c(
      "Shallow Pool", "Medium Pool", "Deep Pool", "Slow Riffle",
      "Fast Riffle", "Raceway", "Faster than Raceway",
      "Faster than Deep Pool"
    ),
    depth_min = c(0, 0.61, 1.37, 0, 0, 0.61, 0.61, 1.37),
    depth_max = c(0.61, 1.37, Inf, 0.61, 0.61, 1.37, 1.37, Inf),
    velocity_min = c(0, 0, 0, 0.30, 0.61, 0.30, 0.61, 0.30),
    velocity_max = c(0.30, 0.30, 0.30, 0.61, Inf, 0.61, Inf, Inf),
    stringsAsFactors = FALSE
  )
  meso_scheme(
    rules,
    name = "Cordero-Harris eight-class mesohabitat scheme",
    description = paste(
      "Eight nominal hydraulic mesohabitat classes defined by depth and",
      "velocity thresholds."
    ),
    depth_units = "m",
    velocity_units = "m/s",
    citation = paste(
      "Cordero, E. and Harris, A. (2026). Semi-Supervised and Supervised",
      "Machine Learning Approaches to Predicting Fluvial Mesohabitats from",
      "Satellite Data. SSRN."
    ),
    source_doi = "10.2139/ssrn.7100727"
  )
}

#' @export
print.meso_scheme <- function(x, ...) {
  cat("<meso_scheme>\n")
  cat("  Name: ", x$name, "\n", sep = "")
  cat("  Units: depth ", x$depth_units, "; velocity ",
      x$velocity_units, "\n", sep = "")
  cat("  Classes: ", nrow(x$rules), "\n", sep = "")
  cat("  Boundaries: ", x$boundary, "\n", sep = "")
  print(x$rules, row.names = FALSE)
  invisible(x)
}

#' Extract the rules from a mesohabitat scheme
#'
#' @param x A `meso_scheme`.
#' @return A plain data frame containing the rule table.
#' @examples
#' meso_scheme_rules(meso_scheme_default())
#' @export
meso_scheme_rules <- function(x) {
  validate_meso_scheme(x)
  x$rules
}

