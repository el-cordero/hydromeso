# Create synthetic example hydraulic rasters

Creates tiny projected depth and velocity rasters that jointly exercise
all eight default classes. No files are written.

## Usage

``` r
mesohabitat_example_rasters()
```

## Value

A named list with `depth` and `velocity` `SpatRaster` objects.

## Examples

``` r
x <- mesohabitat_example_rasters()
classify_mesohabitat_raster(x$depth, x$velocity)
#> class       : SpatRaster
#> size        : 2, 4, 1  (nrow, ncol, nlyr)
#> resolution  : 10, 10  (x, y)
#> extent      : 500000, 500040, 4400000, 4400020  (xmin, xmax, ymin, ymax)
#> coord. ref. : WGS 84 / UTM zone 15N (EPSG:32615)
#> source(s)   : memory
#> categories  : mesohabitat
#> name        :           mesohabitat
#> min value   :          Shallow Pool
#> max value   : Faster than Deep Pool
```
