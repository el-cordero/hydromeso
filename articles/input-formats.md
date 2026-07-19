# Input formats and coordinate reference systems

``` r

library(hydromeso)
```

Data frames and matrices use named or positional field selection. CSV
files are read with base R. Existing columns and row order are retained.

``` r

classify_mesohabitat_table(hydromeso_example, 3, 4)
```

    ##         x       y    depth velocity mesohabitat_class           mesohabitat
    ## 1  500000 4400000 0.200000 0.100000                 1          Shallow Pool
    ## 2  500010 4400010 0.800000 0.100000                 2           Medium Pool
    ## 3  500020 4400020 1.500000 0.100000                 3             Deep Pool
    ## 4  500030 4400030 0.200000 0.400000                 4           Slow Riffle
    ## 5  500040 4400040 0.200000 0.800000                 5           Fast Riffle
    ## 6  500050 4400050 0.800000 0.400000                 6               Raceway
    ## 7  500060 4400060 0.800000 0.800000                 7   Faster than Raceway
    ## 8  500070 4400070 1.500000 0.800000                 8 Faster than Deep Pool
    ## 9  500080 4400080 0.609999 0.299999                 1          Shallow Pool
    ## 10 500090 4400090 0.610000 0.299999                 2           Medium Pool
    ## 11 500100 4400100 1.369999 0.299999                 2           Medium Pool
    ## 12 500110 4400110 1.370000 0.299999                 3             Deep Pool
    ## 13 500120 4400120 0.200000 0.609999                 4           Slow Riffle
    ## 14 500130 4400130 0.200000 0.610000                 5           Fast Riffle
    ## 15 500140 4400140 0.800000 0.609999                 6               Raceway
    ## 16 500150 4400150 0.800000 0.610000                 7   Faster than Raceway
    ## 17 500160 4400160       NA 0.200000                NA                  <NA>
    ## 18 500170 4400170 0.000000 0.000000                 1          Shallow Pool

`SpatVector` objects and vector paths supported by
[`terra::vect()`](https://rspatial.github.io/terra/reference/vect.html)
retain their geometry, CRS, feature order, and attributes. This applies
to points, lines, and polygons. GeoPackage is preferable for examples;
Shapefile export warns and uses short class-field names.

``` r

v <- mesohabitat_example_vector()
classify_mesohabitat_vector(v, "depth", "velocity")
```

    ## class       : SpatVector
    ## geometry    : points
    ## dimensions  : 18, 4  (geometries, attributes)
    ## extent      : 500000, 500170, 4400000, 4400170  (xmin, xmax, ymin, ymax)
    ## coord. ref. : WGS 84 / UTM zone 15N (EPSG:32615)
    ## names       : depth velocity mesohabitat_class  mesohabitat
    ## type        : <num>    <num>             <int>        <chr>
    ## values      :   0.2      0.1                 1 Shallow Pool
    ##                 0.8      0.1                 2  Medium Pool
    ##                 1.5      0.1                 3    Deep Pool
    ##               ...

Rasters can be separate objects/paths or selected layers in one
multilayer raster. Geometry mismatches fail by default. With
`align = "velocity_to_depth"`, velocity is projected or resampled
directly to the depth template with bilinear interpolation. Missing CRS
values are never silently assigned. `assume_crs` assigns a declared CRS
without transforming coordinates and reports that distinction.

An AOI is projected to the raster CRS if necessary. `mask_aoi = TRUE`
performs both a crop and polygon mask; `FALSE` performs only a
rectangular crop.
