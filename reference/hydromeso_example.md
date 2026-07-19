# Synthetic hydraulic observations

A small redistributable data frame with every default mesohabitat class,
exact and adjacent threshold cases, coordinates, and missing values.
Depth is in metres and velocity is in metres per second. Coordinates are
synthetic UTM Zone 15N metres (EPSG:32615).

## Usage

``` r
hydromeso_example
```

## Format

A data frame with 18 rows and four variables:

- x:

  Synthetic easting.

- y:

  Synthetic northing.

- depth:

  Water depth in metres.

- velocity:

  Velocity in metres per second.

## Source

Created synthetically for this package.

## Examples

``` r
hydromeso_example
#>         x       y    depth velocity
#> 1  500000 4400000 0.200000 0.100000
#> 2  500010 4400010 0.800000 0.100000
#> 3  500020 4400020 1.500000 0.100000
#> 4  500030 4400030 0.200000 0.400000
#> 5  500040 4400040 0.200000 0.800000
#> 6  500050 4400050 0.800000 0.400000
#> 7  500060 4400060 0.800000 0.800000
#> 8  500070 4400070 1.500000 0.800000
#> 9  500080 4400080 0.609999 0.299999
#> 10 500090 4400090 0.610000 0.299999
#> 11 500100 4400100 1.369999 0.299999
#> 12 500110 4400110 1.370000 0.299999
#> 13 500120 4400120 0.200000 0.609999
#> 14 500130 4400130 0.200000 0.610000
#> 15 500140 4400140 0.800000 0.609999
#> 16 500150 4400150 0.800000 0.610000
#> 17 500160 4400160       NA 0.200000
#> 18 500170 4400170 0.000000 0.000000
classify_mesohabitat_table(hydromeso_example, "depth", "velocity")
#>         x       y    depth velocity mesohabitat_class           mesohabitat
#> 1  500000 4400000 0.200000 0.100000                 1          Shallow Pool
#> 2  500010 4400010 0.800000 0.100000                 2           Medium Pool
#> 3  500020 4400020 1.500000 0.100000                 3             Deep Pool
#> 4  500030 4400030 0.200000 0.400000                 4           Slow Riffle
#> 5  500040 4400040 0.200000 0.800000                 5           Fast Riffle
#> 6  500050 4400050 0.800000 0.400000                 6               Raceway
#> 7  500060 4400060 0.800000 0.800000                 7   Faster than Raceway
#> 8  500070 4400070 1.500000 0.800000                 8 Faster than Deep Pool
#> 9  500080 4400080 0.609999 0.299999                 1          Shallow Pool
#> 10 500090 4400090 0.610000 0.299999                 2           Medium Pool
#> 11 500100 4400100 1.369999 0.299999                 2           Medium Pool
#> 12 500110 4400110 1.370000 0.299999                 3             Deep Pool
#> 13 500120 4400120 0.200000 0.609999                 4           Slow Riffle
#> 14 500130 4400130 0.200000 0.610000                 5           Fast Riffle
#> 15 500140 4400140 0.800000 0.609999                 6               Raceway
#> 16 500150 4400150 0.800000 0.610000                 7   Faster than Raceway
#> 17 500160 4400160       NA 0.200000                NA                  <NA>
#> 18 500170 4400170 0.000000 0.000000                 1          Shallow Pool
```
