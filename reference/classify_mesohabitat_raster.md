# Classify depth and velocity rasters

Supports separate rasters or a selected pair in one multilayer raster.
Depth is always the geometry template. Continuous velocity is aligned
only when explicitly requested and always with bilinear interpolation.

## Usage

``` r
classify_mesohabitat_raster(
  depth,
  velocity = NULL,
  scheme = meso_scheme_default(),
  depth_layer = NULL,
  velocity_layer = NULL,
  align = c("error", "velocity_to_depth"),
  aoi = NULL,
  mask_aoi = TRUE,
  assume_crs = NULL,
  dry_threshold = NULL,
  invalid = c("error", "NA"),
  filename = "",
  overwrite = FALSE,
  ...
)
```

## Arguments

- depth:

  A `SpatRaster` or raster path. It may contain both selected layers
  when `velocity = NULL`.

- velocity:

  A separate `SpatRaster` or path, or `NULL`.

- scheme:

  A validated `meso_scheme`; values must use its units.

- depth_layer, velocity_layer:

  Optional layer names or positions.

- align:

  `"error"` or `"velocity_to_depth"`.

- aoi:

  Optional `SpatVector` or vector path.

- mask_aoi:

  If `TRUE`, crop and polygon-mask; otherwise rectangular crop.

- assume_crs:

  Optional CRS assigned only to inputs missing a CRS. This does not
  transform coordinates and emits a message.

- dry_threshold, invalid:

  Classification controls.

- filename:

  Optional output filename.

- overwrite:

  Permit overwriting `filename`.

- ...:

  Additional
  [`terra::writeRaster()`](https://rspatial.github.io/terra/reference/writeRaster.html)
  options.

## Value

A categorical integer `SpatRaster` on the (possibly AOI-cropped) depth
geometry, with a complete class table.

## See also

[`classify_mesohabitat_series()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_series.md),
[`write_mesohabitat()`](https://el-cordero.github.io/hydromeso/reference/write_mesohabitat.md)

## Examples

``` r
d <- terra::rast(nrows = 2, ncols = 4, xmin = 0, xmax = 4, ymin = 0, ymax = 2,
                 crs = "EPSG:32615", vals = c(0.2, 0.8, 1.5, 0.2, 0.2, 0.8, 0.8, 1.5))
v <- d
terra::values(v) <- c(0.1, 0.1, 0.1, 0.4, 0.8, 0.4, 0.8, 0.8)
classify_mesohabitat_raster(d, v)
#> class       : SpatRaster
#> size        : 2, 4, 1  (nrow, ncol, nlyr)
#> resolution  : 1, 1  (x, y)
#> extent      : 0, 4, 0, 2  (xmin, xmax, ymin, ymax)
#> coord. ref. : WGS 84 / UTM zone 15N (EPSG:32615)
#> source(s)   : memory
#> categories  : mesohabitat
#> name        :           mesohabitat
#> min value   :          Shallow Pool
#> max value   : Faster than Deep Pool
```
