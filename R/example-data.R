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

#' Create synthetic example hydraulic rasters
#'
#' Creates tiny projected depth and velocity rasters that jointly exercise all
#' eight default classes. No files are written.
#'
#' @return A named list with `depth` and `velocity` `SpatRaster` objects.
#' @examples
#' x <- mesohabitat_example_rasters()
#' classify_mesohabitat_raster(x$depth, x$velocity)
#' @export
mesohabitat_example_rasters <- function() {
  depth <- terra::rast(
    nrows = 2, ncols = 4, xmin = 500000, xmax = 500040,
    ymin = 4400000, ymax = 4400020, crs = "EPSG:32615"
  )
  terra::values(depth) <- c(0.2, 0.8, 1.5, 0.2, 0.2, 0.8, 0.8, 1.5)
  velocity <- terra::rast(depth)
  terra::values(velocity) <- c(0.1, 0.1, 0.1, 0.4, 0.8, 0.4, 0.8, 0.8)
  names(depth) <- "depth_m"; names(velocity) <- "velocity_m_s"
  list(depth = depth, velocity = velocity)
}

