# Compare two classified mesohabitat rasters

Reports nominal transitions, gains and losses by class, unchanged area,
and percentage changed. Numeric differences between IDs are never
interpreted.

## Usage

``` r
compare_mesohabitat(before, after, align = c("error", "after_to_before"))
```

## Arguments

- before, after:

  Single-layer classified `SpatRaster` objects.

- align:

  `"error"` (default) or `"after_to_before"`; explicit alignment uses
  nearest-neighbor resampling because class values are categorical.

## Value

A list of ordinary data frames and scalar area metrics.

## See also

[`summarize_mesohabitat()`](https://el-cordero.github.io/hydromeso/reference/summarize_mesohabitat.md)
