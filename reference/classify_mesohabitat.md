# Classify fluvial mesohabitats

Main dispatcher for numeric values, tables, spatial vectors, and
rasters. All forms use the same lower-inclusive, upper-exclusive rule
engine.

## Usage

``` r
classify_mesohabitat(
  x,
  velocity = NULL,
  depth_col = NULL,
  velocity_col = NULL,
  ...
)
```

## Arguments

- x:

  Numeric depth values, a table, a `SpatVector`, a `SpatRaster`, or a
  supported file path.

- velocity:

  Numeric velocity values or a velocity raster/path.

- depth_col, velocity_col:

  Table/vector column selectors.

- ...:

  Arguments passed to the type-specific classifier.

## Value

The corresponding classified data frame, `SpatVector`, or categorical
`SpatRaster`.

## See also

[`classify_mesohabitat_values()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_values.md),
[`classify_mesohabitat_table()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_table.md),
[`classify_mesohabitat_vector()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_vector.md),
[`classify_mesohabitat_raster()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_raster.md)

## Examples

``` r
classify_mesohabitat(c(0.2, 0.8), c(0.1, 0.4))
#>   depth velocity mesohabitat_class  mesohabitat
#> 1   0.2      0.1                 1 Shallow Pool
#> 2   0.8      0.4                 6      Raceway
```
