two_rules <- function() data.frame(
  class_id = c(1L, 2L), label = c("Slow", "Fast"),
  depth_min = c(0, 0), depth_max = c(Inf, Inf),
  velocity_min = c(0, 0.5), velocity_max = c(0.5, Inf)
)

test_that("complete custom schemes validate and classify exact boundaries", {
  x <- meso_scheme(two_rules())
  expect_s3_class(x, "meso_scheme")
  expect_equal(classify_mesohabitat_values(c(0, 50), c(0.4999, 0.5), x)$mesohabitat_class,
               c(1L, 2L))
})

test_that("scheme structure errors are informative", {
  r <- two_rules()
  expect_error(meso_scheme(r[-1]), "missing required")
  r2 <- r; r2$class_id[2] <- 1
  expect_error(meso_scheme(r2), "Duplicated class")
  r2 <- r; r2$label[2] <- "Slow"
  expect_error(meso_scheme(r2), "Duplicated labels")
  r2 <- r; r2$velocity_min[2] <- 0.4
  expect_error(meso_scheme(r2), "Overlapping classes")
  r2 <- r; r2$velocity_min[2] <- 0.6
  expect_error(meso_scheme(r2), "Uncovered")
  expect_s3_class(meso_scheme(r2, allow_gaps = TRUE), "meso_scheme")
  r2 <- r; r2$velocity_max[1] <- 0
  expect_error(meso_scheme(r2), "minima")
  r2 <- r; r2$depth_min[1] <- -1
  expect_error(meso_scheme(r2), "Negative")
  r2 <- r; r2$depth_min[1] <- Inf
  expect_error(meso_scheme(r2), "Infinite")
})

test_that("intentional custom gaps return NA", {
  r <- two_rules(); r$velocity_max[1] <- 0.4; r$velocity_min[2] <- 0.6
  x <- meso_scheme(r, allow_gaps = TRUE)
  got <- classify_mesohabitat_values(c(1, 1, 1), c(0.2, 0.5, 0.8), x)
  expect_equal(got$mesohabitat_class, c(1L, NA_integer_, 2L))
})
