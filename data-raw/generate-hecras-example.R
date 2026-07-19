library(terra)

# Rebuild the redistributable example from the read-only Cordero-Harris
# HEC-RAS project. Run this script from the package root. The source project is
# never modified.
source_dir <- file.path(
  "/Users/ec/Documents/Projects/USACE/Meso-Change",
  "_data/GIS/Raster/Raw/HECRAS/04_May31_2022"
)

depth_file <- list.files(
  source_dir, pattern = "^Depth .*\\.tif$", full.names = TRUE
)
velocity_file <- list.files(
  source_dir, pattern = "^Velocity .*\\.tif$", full.names = TRUE
)
stopifnot(length(depth_file) == 1L, length(velocity_file) == 1L)

# CRS supplied with the source project for HEC-RAS rasters lacking embedded
# projection metadata: NAD 1983 (CORS96) StatePlane Kansas North, US survey ft.
hecras_crs <- paste(
  "+proj=lcc +lat_0=38.3333333333333 +lon_0=-98",
  "+lat_1=38.7166666666667 +lat_2=39.7833333333333",
  "+x_0=400000 +y_0=0 +ellps=GRS80 +units=us-ft +no_defs +type=crs"
)

depth <- rast(depth_file)
velocity <- rast(velocity_file)
crs(depth) <- hecras_crs
crs(velocity) <- hecras_crs

# Detailed visualization extent used for the manuscript figures.
detail_lonlat <- as.polygons(
  ext(-96.542, -96.514, 39.181, 39.192), crs = "EPSG:4326"
)
detail_projected <- project(detail_lonlat, hecras_crs)

# Crop, aggregate the original 3-ft cells to 18-ft cells, and convert the
# hydraulic values from ft and ft/s to m and m/s.
depth <- aggregate(
  crop(depth, detail_projected), fact = 6, fun = mean, na.rm = TRUE
) * 0.3048
velocity <- aggregate(
  crop(velocity, detail_projected), fact = 6, fun = mean, na.rm = TRUE
) * 0.3048
names(depth) <- "depth_m"
names(velocity) <- "velocity_m_s"

out_dir <- file.path("inst", "extdata", "hecras")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
writeRaster(
  depth, file.path(out_dir, "big_blue_kansas_depth_m.tif"), overwrite = TRUE,
  wopt = list(datatype = "FLT4S", gdal = c("COMPRESS=DEFLATE", "PREDICTOR=3"))
)
writeRaster(
  velocity, file.path(out_dir, "big_blue_kansas_velocity_m_s.tif"),
  overwrite = TRUE,
  wopt = list(datatype = "FLT4S", gdal = c("COMPRESS=DEFLATE", "PREDICTOR=3"))
)
