# Classify paired hydraulic raster scenarios

Named scenarios are paired by unique names. Unnamed inputs are rejected
unless positional pairing is explicitly requested.

## Usage

``` r
classify_mesohabitat_series(
  depth,
  velocity,
  scenario_names = NULL,
  positional = FALSE,
  scheme = meso_scheme_default(),
  ...
)
```

## Arguments

- depth, velocity:

  Multilayer `SpatRaster` objects, lists of rasters, or lists of raster
  paths.

- scenario_names:

  Optional unique names that explicitly define both lists.

- positional:

  Permit explicit position-based pairing when names are absent.

- scheme:

  A `meso_scheme`.

- ...:

  Passed to
  [`classify_mesohabitat_raster()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_raster.md).

## Value

A categorical multilayer `SpatRaster`, one layer per scenario.

## See also

[`mesohabitat_from_median_hydraulics()`](https://el-cordero.github.io/hydromeso/reference/mesohabitat_from_median_hydraulics.md),
[`modal_mesohabitat()`](https://el-cordero.github.io/hydromeso/reference/modal_mesohabitat.md)

## Examples

``` r
d <- terra::rast(nrows = 1, ncols = 2, vals = c(0.2, 0.8), crs = "EPSG:32615")
v <- terra::rast(d); terra::values(v) <- c(0.1, 0.4)
classify_mesohabitat_series(list(low = d), list(low = v))
#> class       : SpatRaster
#> size        : 1, 2, 1  (nrow, ncol, nlyr)
#> resolution  : 180, 180  (x, y)
#> extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : WGS 84 / UTM zone 15N (EPSG:32615)
#> source(s)   : memory
#> categories  : mesohabitat
#> name        :          low
#> min value   : Shallow Pool
#> max value   :      Raceway
```
