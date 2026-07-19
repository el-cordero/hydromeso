# Load example HEC-RAS hydraulic rasters

Loads a compact pair of depth and velocity GeoTIFFs derived from the 31
May 2022 HEC-RAS model output used by Cordero and Harris (Preprint). The
sample shows the Big Blue-Kansas Rivers confluence near Manhattan,
Kansas. Source cells were cropped to the manuscript's detailed
visualization extent, aggregated from 3-foot to 18-foot cells, and
converted to metres and metres per second. The raster geometry remains
in the source project's documented NAD 1983 (CORS96) StatePlane Kansas
North coordinate system.

## Usage

``` r
mesohabitat_example_rasters(paths = FALSE)
```

## Arguments

- paths:

  Logical. If `FALSE` (default), return loaded `SpatRaster` objects. If
  `TRUE`, return their installed GeoTIFF paths.

## Value

A named list with `depth` and `velocity` rasters or file paths.

## References

Cordero, E. and Harris, A. (Preprint). *Semi-Supervised and Supervised
Machine Learning Approaches to Predicting Fluvial Mesohabitats from
Satellite Data*. SSRN.
[doi:10.2139/ssrn.7100727](https://doi.org/10.2139/ssrn.7100727) .

## Examples

``` r
x <- mesohabitat_example_rasters()
classify_mesohabitat_raster(x$depth, x$velocity)
#> class       : SpatRaster
#> size        : 230, 445, 1  (nrow, ncol, nlyr)
#> resolution  : 18, 18  (x, y)
#> extent      : 1725550, 1733560, 312049.5, 316189.5  (xmin, xmax, ymin, ymax)
#> coord. ref. : +proj=lcc +lat_0=38.3333333333333 +lon_0=-98 +lat_1=38.7166666666667 +lat_2=39.7833333333333 +x_0=400000 +y_0=0 +ellps=GRS80 +units=us-ft +no_defs
#> source(s)   : memory
#> categories  : mesohabitat
#> name        :           mesohabitat
#> min value   :          Shallow Pool
#> max value   : Faster than Deep Pool
```
