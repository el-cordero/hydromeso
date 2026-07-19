test_that("default scheme has exact records and metadata", {
  x <- meso_scheme_default()
  expect_s3_class(x, "meso_scheme")
  expect_equal(x$rules$class_id, 1:8)
  expect_equal(x$rules$label, c(
    "Shallow Pool", "Medium Pool", "Deep Pool", "Slow Riffle",
    "Fast Riffle", "Raceway", "Faster than Raceway",
    "Faster than Deep Pool"
  ))
  expect_equal(x$depth_units, "m")
  expect_equal(x$velocity_units, "m/s")
})

test_that("all required exact default threshold cases classify correctly", {
  cases <- data.frame(
    depth = c(0.609999, 0.610000, 1.369999, 1.370000,
              0.609999, 0.609999, 0.609999, 0.610000,
              0.610000, 0.610000, 1.369999, 1.370000,
              1.370000, 0, 100, 100),
    velocity = c(0.299999, 0.299999, 0.299999, 0.299999,
                 0.300000, 0.609999, 0.610000, 0.300000,
                 0.609999, 0.610000, 0.610000, 0.300000,
                 0.610000, 0, 0.1, 100),
    expected = c(1L, 2L, 2L, 3L, 4L, 4L, 5L, 6L,
                 6L, 7L, 7L, 8L, 8L, 1L, 3L, 8L)
  )
  got <- classify_mesohabitat_values(cases$depth, cases$velocity)
  expect_identical(got$mesohabitat_class, cases$expected)
  expect_false(is.ordered(got$mesohabitat))
})

test_that("values immediately around every threshold are stable", {
  eps <- 1e-10
  d <- c(0.61 - eps, 0.61, 0.61 + eps, 1.37 - eps, 1.37, 1.37 + eps)
  expect_equal(classify_mesohabitat_values(d, 0.1)$mesohabitat_class,
               c(1L, 2L, 2L, 2L, 3L, 3L))
  v <- c(0.30 - eps, 0.30, 0.30 + eps, 0.61 - eps, 0.61, 0.61 + eps)
  expect_equal(classify_mesohabitat_values(0.2, v)$mesohabitat_class,
               c(1L, 4L, 4L, 4L, 5L, 5L))
})

test_that("missing invalid and dry values are handled explicitly", {
  got <- classify_mesohabitat_values(c(NA, 0.2, NaN), c(0.1, NA, 0.1),
                                     invalid = "NA")
  expect_true(all(is.na(got$mesohabitat_class)))
  expect_error(classify_mesohabitat_values(-1, 0.1), "negative")
  expect_error(classify_mesohabitat_values(0.1, Inf), "non-finite")
  expect_true(is.na(classify_mesohabitat_values(-1, 0.1,
                                                invalid = "NA")$mesohabitat_class))
  expect_true(is.na(classify_mesohabitat_values(0, 0,
                                                dry_threshold = 0)$mesohabitat_class))
  expect_equal(classify_mesohabitat_values(0, 0)$mesohabitat_class, 1L)
})

test_that("only deliberate scalar recycling is allowed", {
  expect_equal(nrow(classify_mesohabitat_values(0.2, c(0.1, 0.4))), 2L)
  expect_error(classify_mesohabitat_values(1:2, 1:3), "equal lengths")
})

