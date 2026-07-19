#' hydromeso: Classify Fluvial Mesohabitats from Depth and Velocity
#'
#' `hydromeso` applies validated rectangular depth-velocity rules to numeric,
#' tabular, vector, and raster hydraulic data. The default eight-class scheme
#' implements the thresholds used by Cordero and Harris (2026), with the broader
#' depth-velocity mesohabitat framework informed by Aadland (1993).
#'
#' The output is a hydraulic mesohabitat classification based on depth and
#' velocity only. It does not independently establish biological habitat
#' quality or species occurrence. Biological interpretation also depends on
#' species, life stage, stream type, substrate, cover, connectivity, water
#' quality, temperature, flow regime, model resolution, and local validation.
#' Raster outputs inherit uncertainty from hydraulic models and input data;
#' alignment and interpolation can affect cells near thresholds. Class IDs are
#' nominal identifiers rather than ordinal scores.
#'
#' @references
#' Cordero, E. and Harris, A. (2026). *Semi-Supervised and Supervised Machine
#' Learning Approaches to Predicting Fluvial Mesohabitats from Satellite Data*.
#' SSRN, posted July 11, 2026. \doi{10.2139/ssrn.7100727}.
#'
#' Aadland, L. P. (1993). Stream Habitat Types: Their Fish Assemblages and
#' Relationship to Flow. *North American Journal of Fisheries Management*,
#' 13(4), 790-806.
#' \doi{10.1577/1548-8675(1993)013<0790:SHTTFA>2.3.CO;2}.
#' @seealso [meso_scheme_default()], [classify_mesohabitat()]
#' @keywords internal
"_PACKAGE"

