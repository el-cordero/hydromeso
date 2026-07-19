# Mesohabitat derived from median hydraulic surfaces

Calculates cellwise median depth and median velocity, then classifies
those hydraulic surfaces. This is not a numeric median of nominal class
IDs and should not be called "median mesohabitat".

## Usage

``` r
mesohabitat_from_median_hydraulics(
  depth,
  velocity,
  na.rm = TRUE,
  scheme = meso_scheme_default(),
  ...
)
```

## Arguments

- depth, velocity:

  Multilayer `SpatRaster` objects or scenario lists.

- na.rm:

  Remove missing values in the cellwise medians.

- scheme:

  A `meso_scheme`.

- ...:

  Passed to
  [`classify_mesohabitat_raster()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_raster.md).

## Value

A named list containing `median_depth`, `median_velocity`, and
`mesohabitat_from_median_hydraulics`.

## See also

[`classify_mesohabitat_series()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_series.md),
[`modal_mesohabitat()`](https://el-cordero.github.io/hydromeso/reference/modal_mesohabitat.md)
