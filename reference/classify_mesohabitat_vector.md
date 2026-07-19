# Classify spatial vector features from depth and velocity attributes

Geometry, CRS, feature order, and existing attributes are retained.
Points, lines, and polygons are accepted because classification uses
attributes.

## Usage

``` r
classify_mesohabitat_vector(
  x,
  depth_col,
  velocity_col,
  scheme = meso_scheme_default(),
  class_col = "mesohabitat_class",
  label_col = "mesohabitat",
  overwrite = FALSE,
  dry_threshold = NULL,
  invalid = c("error", "NA"),
  layer = NULL,
  ...
)
```

## Arguments

- x:

  A
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
  or vector dataset path supported by `terra`.

- depth_col, velocity_col:

  Attribute names or positions.

- scheme, class_col, label_col, overwrite, dry_threshold, invalid:

  As in
  [`classify_mesohabitat_table()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_table.md).

- layer:

  Optional layer name when reading a multi-layer vector dataset.

- ...:

  Additional arguments passed to
  [`terra::vect()`](https://rspatial.github.io/terra/reference/vect.html)
  for a path.

## Value

A
[`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
with integer class and label attributes.

## See also

[`classify_mesohabitat_raster()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_raster.md),
[`write_mesohabitat()`](https://el-cordero.github.io/hydromeso/reference/write_mesohabitat.md)

## Examples

``` r
x <- data.frame(x = 1:3, y = 1:3, depth = c(0.2, 0.8, 2),
                velocity = c(0.1, 0.4, 0.7))
v <- terra::vect(x, geom = c("x", "y"), crs = "EPSG:32615")
classify_mesohabitat_vector(v, "depth", "velocity")
#> class       : SpatVector
#> geometry    : points
#> dimensions  : 3, 4  (geometries, attributes)
#> extent      : 1, 3, 1, 3  (xmin, xmax, ymin, ymax)
#> coord. ref. : WGS 84 / UTM zone 15N (EPSG:32615)
#> names       : depth velocity mesohabitat_class           mesohabitat
#> type        : <num>    <num>             <int>                 <chr>
#> values      :   0.2      0.1                 1          Shallow Pool
#>                 0.8      0.4                 6               Raceway
#>                   2      0.7                 8 Faster than Deep Pool
```
