# Hydraulic scenarios

``` r

library(hydromeso)
h <- mesohabitat_example_rasters()
d2 <- h$depth * 1.25
v2 <- h$velocity * 1.15
depth <- list(low = h$depth, high = d2)
velocity <- list(low = h$velocity, high = v2)
```

Unique names pair dates or discharges safely. Unmatched or duplicated
names are rejected. Positional pairing is available only when explicitly
requested.

``` r

scenarios <- classify_mesohabitat_series(depth, velocity)
summarize_mesohabitat(scenarios)
```

    ##    scenario class_id                 label cell_count  area_m2   hectares
    ## 1       low        1          Shallow Pool          1 100.0801 0.01000801
    ## 2       low        2           Medium Pool          1 100.0800 0.01000800
    ## 3       low        3             Deep Pool          1 100.0800 0.01000800
    ## 4       low        4           Slow Riffle          1 100.0801 0.01000801
    ## 5       low        5           Fast Riffle          1 100.0800 0.01000800
    ## 6       low        6               Raceway          1 100.0800 0.01000800
    ## 7       low        7   Faster than Raceway          1 100.0800 0.01000800
    ## 8       low        8 Faster than Deep Pool          1 100.0800 0.01000800
    ## 9      high        1          Shallow Pool          1 100.0801 0.01000801
    ## 10     high        2           Medium Pool          1 100.0800 0.01000800
    ## 11     high        3             Deep Pool          1 100.0800 0.01000800
    ## 12     high        4           Slow Riffle          1 100.0801 0.01000801
    ## 13     high        5           Fast Riffle          1 100.0800 0.01000800
    ## 14     high        6               Raceway          1 100.0800 0.01000800
    ## 15     high        7   Faster than Raceway          1 100.0800 0.01000800
    ## 16     high        8 Faster than Deep Pool          1 100.0800 0.01000800
    ##    square_kilometres      acres percentage
    ## 1       0.0001000801 0.02473032       12.5
    ## 2       0.0001000800 0.02473032       12.5
    ## 3       0.0001000800 0.02473032       12.5
    ## 4       0.0001000801 0.02473032       12.5
    ## 5       0.0001000800 0.02473032       12.5
    ## 6       0.0001000800 0.02473032       12.5
    ## 7       0.0001000800 0.02473032       12.5
    ## 8       0.0001000800 0.02473032       12.5
    ## 9       0.0001000801 0.02473032       12.5
    ## 10      0.0001000800 0.02473032       12.5
    ## 11      0.0001000800 0.02473032       12.5
    ## 12      0.0001000801 0.02473032       12.5
    ## 13      0.0001000800 0.02473032       12.5
    ## 14      0.0001000800 0.02473032       12.5
    ## 15      0.0001000800 0.02473032       12.5
    ## 16      0.0001000800 0.02473032       12.5

The following operation takes median depth and median velocity first and
then classifies those two surfaces:

``` r

median_result <- mesohabitat_from_median_hydraulics(depth, velocity)
names(median_result)
```

    ## [1] "median_depth"                       "median_velocity"                   
    ## [3] "mesohabitat_from_median_hydraulics"

This is mesohabitat derived from median hydraulics, not “median
mesohabitat.” The modal nominal class is a different operation. Ties can
return `NA` or the lowest class identifier as a deterministic
identifier-only convention.

``` r

modal_mesohabitat(scenarios, ties = "NA")
```

    ## class       : SpatRaster
    ## size        : 2, 4, 1  (nrow, ncol, nlyr)
    ## resolution  : 10, 10  (x, y)
    ## extent      : 500000, 500040, 4400000, 4400020  (xmin, xmax, ymin, ymax)
    ## coord. ref. : WGS 84 / UTM zone 15N (EPSG:32615)
    ## source(s)   : memory
    ## categories  : mesohabitat
    ## name        :     modal_mesohabitat
    ## min value   :          Shallow Pool
    ## max value   : Faster than Deep Pool

``` r

compare_mesohabitat(scenarios[[1]], scenarios[[2]])
```

    ## $transitions
    ##   from_class to_class cell_count  area_m2
    ## 1          1        1          1 100.0801
    ## 2          2        2          1 100.0800
    ## 3          3        3          1 100.0800
    ## 4          4        4          1 100.0801
    ## 5          5        5          1 100.0800
    ## 6          6        6          1 100.0800
    ## 7          7        7          1 100.0800
    ## 8          8        8          1 100.0800
    ## 
    ## $gains
    ##   class_id area_m2
    ## 1        1       0
    ## 2        2       0
    ## 3        3       0
    ## 4        4       0
    ## 5        5       0
    ## 6        6       0
    ## 7        7       0
    ## 8        8       0
    ## 
    ## $losses
    ##   class_id area_m2
    ## 1        1       0
    ## 2        2       0
    ## 3        3       0
    ## 4        4       0
    ## 5        5       0
    ## 6        6       0
    ## 7        7       0
    ## 8        8       0
    ## 
    ## $unchanged_area_m2
    ## [1] 800.6404
    ## 
    ## $percentage_changed
    ## [1] 0
