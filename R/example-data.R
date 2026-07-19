#' Synthetic hydraulic observations
#'
#' A small redistributable data frame with every default mesohabitat class,
#' exact and adjacent threshold cases, coordinates, and missing values. Depth is
#' in metres and velocity is in metres per second. Coordinates are synthetic
#' UTM Zone 15N metres (EPSG:32615).
#'
#' @format A data frame with 18 rows and four variables:
#' \describe{
#'   \item{x}{Synthetic easting.}
#'   \item{y}{Synthetic northing.}
#'   \item{depth}{Water depth in metres.}
#'   \item{velocity}{Velocity in metres per second.}
#' }
#' @examples
#' hydromeso_example
#' classify_mesohabitat_table(hydromeso_example, "depth", "velocity")
#' @source Created synthetically for this package.
"hydromeso_example"

#' Create a synthetic example spatial vector
#'
#' @return A point `terra::SpatVector` in EPSG:32615 made from
#'   [hydromeso_example].
#' @examples
#' mesohabitat_example_vector()
#' @export
mesohabitat_example_vector <- function() {
  terra::vect(hydromeso_example, geom = c("x", "y"), crs = "EPSG:32615")
}

#' Load example HEC-RAS hydraulic rasters
#'
#' Loads a compact pair of depth and velocity GeoTIFFs derived from the 31 May
#' 2022 HEC-RAS model output used by Cordero and Harris (Preprint). The sample
#' shows the Big Blue-Kansas Rivers confluence near Manhattan, Kansas. Source
#' cells were cropped to the manuscript's detailed visualization extent,
#' aggregated from 3-foot to 18-foot cells, and converted to metres and metres
#' per second. The raster geometry remains in the source project's documented
#' NAD 1983 (CORS96) StatePlane Kansas North coordinate system.
#'
#' @param paths Logical. If `FALSE` (default), return loaded `SpatRaster`
#'   objects. If `TRUE`, return their installed GeoTIFF paths.
#' @return A named list with `depth` and `velocity` rasters or file paths.
#' @references Cordero, E. and Harris, A. (Preprint). *Semi-Supervised and
#' Supervised Machine Learning Approaches to Predicting Fluvial Mesohabitats
#' from Satellite Data*. SSRN. \doi{10.2139/ssrn.7100727}.
#' @examples
#' x <- mesohabitat_example_rasters()
#' classify_mesohabitat_raster(x$depth, x$velocity)
#' @export
mesohabitat_example_rasters <- function(paths = FALSE) {
  if (!is.logical(paths) || length(paths) != 1L || is.na(paths)) {
    stop("`paths` must be TRUE or FALSE.", call. = FALSE)
  }
  raster_paths <- c(
    depth = system.file(
      "extdata", "hecras", "big_blue_kansas_depth_m.tif",
      package = "hydromeso", mustWork = TRUE
    ),
    velocity = system.file(
      "extdata", "hecras", "big_blue_kansas_velocity_m_s.tif",
      package = "hydromeso", mustWork = TRUE
    )
  )
  if (paths) return(as.list(raster_paths))
  list(depth = terra::rast(raster_paths[["depth"]]),
       velocity = terra::rast(raster_paths[["velocity"]]))
}
