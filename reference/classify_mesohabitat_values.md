# Classify numeric depth and velocity values

Applies one authoritative rule-table engine. Lower bounds are inclusive,
upper bounds are exclusive, missing inputs remain missing, and zero
depth and velocity are classified mathematically (Class 1 under the
default scheme).

## Usage

``` r
classify_mesohabitat_values(
  depth,
  velocity,
  scheme = meso_scheme_default(),
  dry_threshold = NULL,
  invalid = c("error", "NA")
)
```

## Arguments

- depth, velocity:

  Numeric vectors in the units declared by `scheme`. Length-one inputs
  may be deliberately recycled; other unequal lengths fail.

- scheme:

  A validated `meso_scheme`.

- dry_threshold:

  `NULL` to preserve the scheme exactly, or a nonnegative depth at or
  below which classifications become `NA`.

- invalid:

  Either `"error"` (default) or `"NA"` for negative and infinite
  observations. Values are never clamped or replaced with zero.

## Value

A data frame containing depth, velocity, integer `mesohabitat_class`,
and unordered factor `mesohabitat`.

## References

Cordero, E. and Harris, A. (Preprint). SSRN.
[doi:10.2139/ssrn.7100727](https://doi.org/10.2139/ssrn.7100727) .

## See also

[`classify_mesohabitat()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat.md),
[`classify_mesohabitat_table()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_table.md),
[`convert_hydraulic_units()`](https://el-cordero.github.io/hydromeso/reference/convert_hydraulic_units.md)

## Examples

``` r
classify_mesohabitat_values(c(0.2, 0.61, 1.37), c(0.1, 0.61, 0.3))
#>   depth velocity mesohabitat_class           mesohabitat
#> 1  0.20     0.10                 1          Shallow Pool
#> 2  0.61     0.61                 7   Faster than Raceway
#> 3  1.37     0.30                 8 Faster than Deep Pool
```
