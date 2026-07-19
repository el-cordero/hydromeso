# Classify a table of depth and velocity observations

Classify a table of depth and velocity observations

## Usage

``` r
classify_mesohabitat_table(
  x,
  depth_col,
  velocity_col,
  scheme = meso_scheme_default(),
  class_col = "mesohabitat_class",
  label_col = "mesohabitat",
  keep_input = TRUE,
  overwrite = FALSE,
  dry_threshold = NULL,
  invalid = c("error", "NA"),
  ...
)
```

## Arguments

- x:

  A data frame, matrix, or path to a CSV file.

- depth_col, velocity_col:

  Column names or one-based positions.

- scheme:

  A validated `meso_scheme`.

- class_col, label_col:

  Names for appended output fields.

- keep_input:

  Keep all input columns; if `FALSE`, return selected inputs and
  classifications only.

- overwrite:

  Permit replacing existing output columns.

- dry_threshold, invalid:

  Passed to
  [`classify_mesohabitat_values()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_values.md).

- ...:

  Additional arguments passed to
  [`utils::read.csv()`](https://rdrr.io/r/utils/read.table.html) for a
  path.

## Value

A data frame in the original row order.

## See also

[`classify_mesohabitat_vector()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_vector.md),
[`write_mesohabitat()`](https://el-cordero.github.io/hydromeso/reference/write_mesohabitat.md)

## Examples

``` r
x <- data.frame(site = letters[1:3], d = c(0.2, 0.8, 2), v = c(0.1, 0.4, 0.7))
classify_mesohabitat_table(x, "d", "v")
#>   site   d   v mesohabitat_class           mesohabitat
#> 1    a 0.2 0.1                 1          Shallow Pool
#> 2    b 0.8 0.4                 6               Raceway
#> 3    c 2.0 0.7                 8 Faster than Deep Pool
```
