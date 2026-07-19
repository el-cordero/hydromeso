test_that("tables preserve order attributes and selected columns", {
  x <- data.frame(id = 3:1, d = c("0.2", "0.8", NA), v = c("0.1", "0.4", "0.2"))
  got <- classify_mesohabitat_table(x, "d", "v")
  expect_equal(got$id, x$id)
  expect_equal(got$mesohabitat_class, c(1L, 6L, NA_integer_))
  expect_equal(classify_mesohabitat_table(x, 2, 3)$mesohabitat_class,
               got$mesohabitat_class)
  x$mesohabitat <- "old"
  expect_error(classify_mesohabitat_table(x, "d", "v"), "already exist")
  x2 <- x; x2$d[1] <- "bad"
  expect_error(classify_mesohabitat_table(x2, "d", "v", overwrite = TRUE),
               "could not be converted")
})

test_that("CSV paths classify with the table engine", {
  p <- tempfile(fileext = ".csv")
  utils::write.csv(data.frame(d = c(0.2, 0.8), v = c(0.1, 0.4)), p, row.names = FALSE)
  expect_equal(classify_mesohabitat_table(p, "d", "v")$mesohabitat_class,
               c(1L, 6L))
})

test_that("tab-delimited paths classify with the table engine", {
  p <- tempfile(fileext = ".tsv")
  utils::write.table(data.frame(d = c(0.2, 0.8), v = c(0.1, 0.4)), p,
                     row.names = FALSE, sep = "\t")
  expect_equal(classify_mesohabitat_table(p, "d", "v")$mesohabitat_class,
               c(1L, 6L))
})

test_that("SpatVector classification preserves geometry CRS and attributes", {
  x <- data.frame(x = 1:3, y = 3:1, id = letters[1:3],
                  d = c(0.2, 0.8, 2), v = c(0.1, 0.4, 0.8))
  v <- terra::vect(x, geom = c("x", "y"), crs = "EPSG:32615")
  got <- classify_mesohabitat_vector(v, "d", "v")
  expect_s4_class(got, "SpatVector")
  expect_true(terra::same.crs(v, got))
  expect_equal(terra::crds(v), terra::crds(got))
  expect_equal(got$id, v$id)
  expect_equal(got$mesohabitat_class, c(1L, 6L, 8L))
})

.tiny_hydraulics <- function() {
  d <- terra::rast(nrows = 2, ncols = 4, xmin = 0, xmax = 4, ymin = 0, ymax = 2,
                   crs = "EPSG:32615")
  terra::values(d) <- c(0.2, 0.8, 1.5, 0.2, 0.2, 0.8, 0.8, 1.5)
  v <- d
  terra::values(v) <- c(0.1, 0.1, 0.1, 0.4, 0.8, 0.4, 0.8, 0.8)
  list(d = d, v = v)
}

test_that("raster output matches the common engine and has categories", {
  z <- .tiny_hydraulics()
  got <- classify_mesohabitat_raster(z$d, z$v)
  expect_s4_class(got, "SpatRaster")
  expect_true(terra::is.factor(got))
  expect_equal(as.integer(terra::values(got)[, 1]), 1:8)
  expect_equal(nrow(terra::levels(got)[[1]]), 8L)
  tab <- classify_mesohabitat_table(
    data.frame(d = terra::values(z$d)[, 1], v = terra::values(z$v)[, 1]), "d", "v")
  expect_equal(as.integer(terra::values(got)[, 1]), tab$mesohabitat_class)
})

test_that("raster geometry mismatches require explicit alignment", {
  z <- .tiny_hydraulics()
  coarse <- terra::aggregate(z$v, 2)
  expect_error(classify_mesohabitat_raster(z$d, coarse), "geometry differs")
  got <- classify_mesohabitat_raster(z$d, coarse, align = "velocity_to_depth")
  expect_true(isTRUE(terra::compareGeom(z$d, got, stopOnError = FALSE)))
})

test_that("combined raster layer selection and AOI work", {
  z <- .tiny_hydraulics(); names(z$d) <- "depth"; names(z$v) <- "velocity"
  both <- c(z$d, z$v)
  got <- classify_mesohabitat_raster(both, depth_layer = "depth",
                                     velocity_layer = "velocity")
  expect_equal(as.integer(terra::values(got)[, 1]), 1:8)
  aoi <- terra::as.polygons(terra::ext(0, 2, 0, 2), crs = terra::crs(z$d))
  cropped <- classify_mesohabitat_raster(z$d, z$v, aoi = aoi)
  expect_lt(terra::ncell(cropped), terra::ncell(got))
})

test_that("file-backed raster output retains integer values and categories", {
  z <- .tiny_hydraulics(); p <- tempfile(fileext = ".tif")
  got <- classify_mesohabitat_raster(z$d, z$v, filename = p)
  reread <- terra::rast(p)
  expect_equal(as.integer(terra::values(reread)[, 1]), 1:8)
  expect_true(terra::is.factor(reread))
  expect_equal(nrow(terra::levels(reread)[[1]]), 8L)
  expect_match(terra::datatype(reread), "INT1U")
  expect_true(file.exists(terra::sources(got)))
})

test_that("explicit unit conversion is correct", {
  got <- convert_hydraulic_units(1, 1, "ft", "m", "ft/s", "m/s")
  expect_equal(got$depth, 0.3048)
  expect_equal(got$velocity, 0.3048)
})

test_that("packaged HEC-RAS rasters are real, aligned metric examples", {
  paths <- mesohabitat_example_rasters(paths = TRUE)
  expect_true(all(file.exists(unlist(paths))))

  x <- mesohabitat_example_rasters()
  expect_s4_class(x$depth, "SpatRaster")
  expect_s4_class(x$velocity, "SpatRaster")
  expect_true(terra::compareGeom(x$depth, x$velocity, stopOnError = FALSE))
  expect_equal(names(x$depth), "depth_m")
  expect_equal(names(x$velocity), "velocity_m_s")
  expect_equal(c(terra::nrow(x$depth), terra::ncol(x$depth)), c(230L, 445L))
  expect_gt(terra::global(x$depth, "max", na.rm = TRUE)[1, 1], 1.37)
  expect_gt(terra::global(x$velocity, "max", na.rm = TRUE)[1, 1], 0.61)
  expect_equal(nrow(terra::freq(classify_mesohabitat_raster(
    x$depth, x$velocity
  ))), 8L)
  expect_error(mesohabitat_example_rasters(paths = NA), "TRUE or FALSE")
})
