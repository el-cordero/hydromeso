# Construct a mesohabitat classification scheme

Creates and validates a rectangular classification in depth-velocity
space. Every lower bound is inclusive and every upper bound is
exclusive. Class IDs are nominal identifiers, not ecological ranks.

## Usage

``` r
meso_scheme(
  rules,
  name = "Custom mesohabitat scheme",
  description = NULL,
  depth_units = "m",
  velocity_units = "m/s",
  citation = NULL,
  source_doi = NULL,
  allow_gaps = FALSE,
  allow_negative = FALSE
)
```

## Arguments

- rules:

  A data frame with `class_id`, `label`, `depth_min`, `depth_max`,
  `velocity_min`, and `velocity_max`.

- name:

  Nonempty scheme name.

- description:

  Optional description.

- depth_units, velocity_units:

  Nonempty unit labels.

- citation:

  Optional source citation.

- source_doi:

  Optional source DOI.

- allow_gaps:

  Whether uncovered regions at nonnegative depth and velocity are
  permitted.

- allow_negative:

  Whether negative rule minima are permitted.

## Value

An object of class `meso_scheme`.

## See also

[`validate_meso_scheme()`](https://el-cordero.github.io/hydromeso/reference/validate_meso_scheme.md),
[`meso_scheme_default()`](https://el-cordero.github.io/hydromeso/reference/meso_scheme_default.md),
[`classify_mesohabitat_values()`](https://el-cordero.github.io/hydromeso/reference/classify_mesohabitat_values.md)

## Examples

``` r
rules <- data.frame(
  class_id = c(1L, 2L), label = c("Slow", "Fast"),
  depth_min = c(0, 0), depth_max = c(Inf, Inf),
  velocity_min = c(0, 0.5), velocity_max = c(0.5, Inf)
)
meso_scheme(rules, name = "Two velocity classes")
```
