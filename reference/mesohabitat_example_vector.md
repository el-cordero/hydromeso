# Create a synthetic example spatial vector

Create a synthetic example spatial vector

## Usage

``` r
mesohabitat_example_vector()
```

## Value

A point
[`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
in EPSG:32615 made from
[hydromeso_example](https://el-cordero.github.io/hydromeso/reference/hydromeso_example.md).

## Examples

``` r
mesohabitat_example_vector()
#> class       : SpatVector
#> geometry    : points
#> dimensions  : 18, 2  (geometries, attributes)
#> extent      : 500000, 500170, 4400000, 4400170  (xmin, xmax, ymin, ymax)
#> coord. ref. : WGS 84 / UTM zone 15N (EPSG:32615)
#> names       : depth velocity
#> type        : <num>    <num>
#> values      :   0.2      0.1
#>                 0.8      0.1
#>                 1.5      0.1
#>               ...
```
