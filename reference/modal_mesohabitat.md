# Modal mesohabitat across scenarios

Computes the most frequent nominal class per cell. It never calculates a
numeric median of class IDs.

## Usage

``` r
modal_mesohabitat(x, ties = c("NA", "lowest_class"), na.rm = TRUE)
```

## Arguments

- x:

  A classified multilayer `SpatRaster`.

- ties:

  `"NA"` (default) or `"lowest_class"`.

- na.rm:

  Ignore missing scenarios.

## Value

A single categorical `SpatRaster`.
