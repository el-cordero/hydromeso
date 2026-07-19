make_scenarios <- function() {
  d1 <- terra::rast(nrows = 2, ncols = 2, xmin = 0, xmax = 20, ymin = 0, ymax = 20,
                    crs = "EPSG:32615", vals = c(0.2, 0.8, 1.5, 0.2))
  d2 <- d1; terra::values(d2) <- c(0.4, 1, 2, 0.3)
  v1 <- d1; terra::values(v1) <- c(0.1, 0.4, 0.1, 0.8)
  v2 <- d1; terra::values(v2) <- c(0.4, 0.7, 0.5, 0.2)
  list(d = list(low = d1, high = d2), v = list(low = v1, high = v2))
}

test_that("scenario pairing is safe and outputs named categorical layers", {
  z <- make_scenarios(); got <- classify_mesohabitat_series(z$d, z$v)
  expect_equal(names(got), c("low", "high"))
  expect_true(all(terra::is.factor(got)))
  bad <- z$v; names(bad) <- c("low", "other")
  expect_error(classify_mesohabitat_series(z$d, bad), "do not match")
  expect_error(classify_mesohabitat_series(unname(z$d), unname(z$v)), "names are required")
  expect_equal(names(classify_mesohabitat_series(unname(z$d), unname(z$v), positional = TRUE)),
               c("scenario_1", "scenario_2"))
})

test_that("median hydraulics are classified and modal ties are explicit", {
  z <- make_scenarios(); got <- mesohabitat_from_median_hydraulics(z$d, z$v)
  expect_named(got, c("median_depth", "median_velocity", "mesohabitat_from_median_hydraulics"))
  expect_equal(as.numeric(terra::values(got$median_depth)[1, 1]), 0.3)
  s <- classify_mesohabitat_series(z$d, z$v)
  expect_true(anyNA(terra::values(modal_mesohabitat(s, ties = "NA"))))
  expect_false(anyNA(terra::values(modal_mesohabitat(s, ties = "lowest_class"))))
})

test_that("table and raster summaries include complete classes", {
  tab <- classify_mesohabitat_table(data.frame(d = c(0.2, 0.8, NA), v = c(0.1, 0.4, 0.2)), "d", "v")
  s <- summarize_mesohabitat(tab)
  expect_equal(nrow(s), 8L); expect_equal(sum(s$record_count), 2L)
  expect_equal(unique(s$missing_count), 1L); expect_equal(sum(s$percentage), 100)
  z <- make_scenarios(); r <- classify_mesohabitat_series(z$d, z$v)
  rs <- summarize_mesohabitat(r)
  expect_equal(nrow(rs), 16L)
  expect_equal(as.numeric(tapply(rs$percentage, rs$scenario, sum)), c(100, 100))
})

test_that("polygon and line summaries report physical measures", {
  p <- terra::as.polygons(terra::rast(nrows = 1, ncols = 2, xmin = 0, xmax = 20,
                                      ymin = 0, ymax = 10, crs = "EPSG:32615"))
  p$depth <- c(0.2, 0.8); p$velocity <- c(0.1, 0.4)
  pc <- classify_mesohabitat_vector(p, "depth", "velocity")
  ps <- summarize_mesohabitat(pc)
  expect_equal(sum(ps$area_m2), 200, tolerance = 0.1)
  expect_equal(sum(ps$percentage_area), 100)

  ln <- terra::vect("LINESTRING (0 0, 10 0)", crs = "EPSG:32615")
  ln <- rbind(ln, terra::vect("LINESTRING (0 1, 20 1)", crs = "EPSG:32615"))
  ln$depth <- c(0.2, 0.8); ln$velocity <- c(0.1, 0.4)
  lc <- classify_mesohabitat_vector(ln, "depth", "velocity")
  ls <- summarize_mesohabitat(lc)
  expect_equal(sum(ls$length_m), 30, tolerance = 0.1)
  expect_equal(sum(ls$percentage_length), 100)
})

test_that("raster comparisons report transitions and changed percentage", {
  z <- make_scenarios(); r <- classify_mesohabitat_series(z$d, z$v)
  cmp <- compare_mesohabitat(r[[1]], r[[2]])
  expect_named(cmp, c("transitions", "gains", "losses", "unchanged_area_m2", "percentage_changed"))
  expect_true(cmp$percentage_changed >= 0 && cmp$percentage_changed <= 100)
})

test_that("plots run and preserve palette mapping", {
  p <- tempfile(fileext = ".pdf"); grDevices::pdf(p)
  expect_no_error(plot_meso_scheme())
  tab <- classify_mesohabitat_values(c(0.2, 0.8), c(0.1, 0.4))
  expect_no_error(plot_mesohabitat(tab))
  grDevices::dev.off()
  expect_equal(names(mesohabitat_palette()), meso_scheme_default()$rules$label)
})

test_that("table raster and vector exports protect outputs and write sidecars", {
  d <- tempfile(); dir.create(d)
  tab <- classify_mesohabitat_values(c(0.2, 0.8), c(0.1, 0.4))
  p <- file.path(d, "classes.csv")
  expect_equal(write_mesohabitat(tab, p), normalizePath(p))
  expect_true(file.exists(p)); expect_true(file.exists(file.path(d, "classes_classes.csv")))
  expect_error(write_mesohabitat(tab, p), "exists")
  z <- make_scenarios(); r <- classify_mesohabitat_series(z$d, z$v)[[1]]
  rp <- file.path(d, "raster_classes.tif")
  expect_true(file.exists(write_mesohabitat(r, rp)))
  v <- terra::vect(data.frame(x = 1:2, y = 1:2, depth = c(.2, .8), velocity = c(.1, .4)),
                   geom = c("x", "y"), crs = "EPSG:32615")
  v <- classify_mesohabitat_vector(v, "depth", "velocity")
  vp <- file.path(d, "vector_classes.gpkg")
  expect_true(file.exists(write_mesohabitat(v, vp)))
  shp <- file.path(d, "vector_classes.shp")
  expect_warning(write_mesohabitat(v, shp, sidecar = FALSE), "field names")
  reread <- terra::vect(shp)
  expect_true(all(c("meso_cls", "mesohab") %in% names(reread)))
})
