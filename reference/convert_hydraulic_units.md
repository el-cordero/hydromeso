# Convert hydraulic depth and velocity units

Explicitly converts values before classification. The default scheme
remains defined at exactly 0.61 and 1.37 m and 0.30 and 0.61 m/s;
converted imperial values can differ slightly at rounded published
boundaries.

## Usage

``` r
convert_hydraulic_units(
  depth = NULL,
  velocity = NULL,
  depth_from = "m",
  depth_to = "m",
  velocity_from = "m/s",
  velocity_to = "m/s"
)
```

## Arguments

- depth, velocity:

  Optional numeric values.

- depth_from, depth_to:

  One of `"m"`, `"cm"`, or `"ft"`.

- velocity_from, velocity_to:

  One of `"m/s"`, `"cm/s"`, or `"ft/s"`.

## Value

A list with converted `depth` and `velocity`.

## Examples

``` r
convert_hydraulic_units(depth = 2, velocity = 1,
                        depth_from = "ft", velocity_from = "ft/s")
#> $depth
#> [1] 0.6096
#> 
#> $velocity
#> [1] 0.3048
#> 
```
