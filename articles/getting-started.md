# Getting started with hydromeso

``` r

library(hydromeso)
```

`hydromeso` classifies depth and velocity into nominal hydraulic
mesohabitats. Install a local source package with
`install.packages(path, repos = NULL, type = "source")`.

## Exact default table

``` r

meso_scheme_rules(meso_scheme_default())
```

    ##   class_id                 label depth_min depth_max velocity_min velocity_max
    ## 1        1          Shallow Pool      0.00      0.61         0.00         0.30
    ## 2        2           Medium Pool      0.61      1.37         0.00         0.30
    ## 3        3             Deep Pool      1.37       Inf         0.00         0.30
    ## 4        4           Slow Riffle      0.00      0.61         0.30         0.61
    ## 5        5           Fast Riffle      0.00      0.61         0.61          Inf
    ## 6        6               Raceway      0.61      1.37         0.30         0.61
    ## 7        7   Faster than Raceway      0.61      1.37         0.61          Inf
    ## 8        8 Faster than Deep Pool      1.37       Inf         0.30          Inf

All lower bounds are inclusive and all upper bounds are exclusive. Exact
depths 0.61 and 1.37 enter the medium and deep ranges; exact velocities
0.30 and 0.61 enter the moderate and high ranges.

## Values and tables

``` r

classify_mesohabitat_values(c(0, 0.61, 1.37), c(0, 0.30, 0.61))
```

    ##   depth velocity mesohabitat_class           mesohabitat
    ## 1  0.00     0.00                 1          Shallow Pool
    ## 2  0.61     0.30                 6               Raceway
    ## 3  1.37     0.61                 8 Faster than Deep Pool

``` r

tab <- classify_mesohabitat_table(hydromeso_example, "depth", "velocity")
summarize_mesohabitat(tab)
```

    ##   class_id                 label record_count percentage missing_count
    ## 1        1          Shallow Pool            3  17.647059             1
    ## 2        2           Medium Pool            3  17.647059             1
    ## 3        3             Deep Pool            2  11.764706             1
    ## 4        4           Slow Riffle            2  11.764706             1
    ## 5        5           Fast Riffle            2  11.764706             1
    ## 6        6               Raceway            2  11.764706             1
    ## 7        7   Faster than Raceway            2  11.764706             1
    ## 8        8 Faster than Deep Pool            1   5.882353             1

## Rasters and export

``` r

h <- mesohabitat_example_rasters()
r <- classify_mesohabitat_raster(h$depth, h$velocity)
summarize_mesohabitat(r)
```

    ##      scenario class_id                 label cell_count  area_m2   hectares
    ## 1 mesohabitat        1          Shallow Pool          1 100.0801 0.01000801
    ## 2 mesohabitat        2           Medium Pool          1 100.0800 0.01000800
    ## 3 mesohabitat        3             Deep Pool          1 100.0800 0.01000800
    ## 4 mesohabitat        4           Slow Riffle          1 100.0801 0.01000801
    ## 5 mesohabitat        5           Fast Riffle          1 100.0800 0.01000800
    ## 6 mesohabitat        6               Raceway          1 100.0800 0.01000800
    ## 7 mesohabitat        7   Faster than Raceway          1 100.0800 0.01000800
    ## 8 mesohabitat        8 Faster than Deep Pool          1 100.0800 0.01000800
    ##   square_kilometres      acres percentage
    ## 1      0.0001000801 0.02473032       12.5
    ## 2      0.0001000800 0.02473032       12.5
    ## 3      0.0001000800 0.02473032       12.5
    ## 4      0.0001000801 0.02473032       12.5
    ## 5      0.0001000800 0.02473032       12.5
    ## 6      0.0001000800 0.02473032       12.5
    ## 7      0.0001000800 0.02473032       12.5
    ## 8      0.0001000800 0.02473032       12.5

``` r

plot_mesohabitat(r)
```

![](getting-started_files/figure-html/unnamed-chunk-3-1.png)

``` r

out <- file.path(tempdir(), "mesohabitat.tif")
write_mesohabitat(r, out, sidecar = TRUE, overwrite = TRUE)
```

The classes describe hydraulic conditions only. They are not biological
habitat-suitability scores, and the integer IDs are nominal.
