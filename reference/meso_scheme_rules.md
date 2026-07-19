# Extract the rules from a mesohabitat scheme

Extract the rules from a mesohabitat scheme

## Usage

``` r
meso_scheme_rules(x)
```

## Arguments

- x:

  A `meso_scheme`.

## Value

A plain data frame containing the rule table.

## Examples

``` r
meso_scheme_rules(meso_scheme_default())
#>   class_id                 label depth_min depth_max velocity_min velocity_max
#> 1        1          Shallow Pool      0.00      0.61         0.00         0.30
#> 2        2           Medium Pool      0.61      1.37         0.00         0.30
#> 3        3             Deep Pool      1.37       Inf         0.00         0.30
#> 4        4           Slow Riffle      0.00      0.61         0.30         0.61
#> 5        5           Fast Riffle      0.00      0.61         0.61          Inf
#> 6        6               Raceway      0.61      1.37         0.30         0.61
#> 7        7   Faster than Raceway      0.61      1.37         0.61          Inf
#> 8        8 Faster than Deep Pool      1.37       Inf         0.30          Inf
```
