# Validate a mesohabitat classification scheme

Performs deterministic breakpoint-based checks of rule structure,
metadata, overlaps, gaps, and reachability. The nonnegative
depth-velocity plane is the required domain unless gaps are allowed. No
random sampling is used.

## Usage

``` r
validate_meso_scheme(x)
```

## Arguments

- x:

  A `meso_scheme` object.

## Value

The validated object, invisibly.

## See also

[`meso_scheme()`](https://el-cordero.github.io/hydromeso/reference/meso_scheme.md)

## Examples

``` r
validate_meso_scheme(meso_scheme_default())
```
