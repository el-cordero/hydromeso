# Summarize mesohabitat classes

Summarizes classified tables, vectors, rasters, and raster scenarios.
Raster areas use
[`terra::cellSize()`](https://rspatial.github.io/terra/reference/cellSize.html)
and are valid for projected or geographic grids.

## Usage

``` r
summarize_mesohabitat(
  x,
  class_col = "mesohabitat_class",
  label_col = "mesohabitat",
  denominator = c("classified", "non_na", "mask"),
  analysis_mask = NULL
)
```

## Arguments

- x:

  A classified data frame, `SpatVector`, or `SpatRaster`.

- class_col, label_col:

  Classification field names for tables/vectors.

- denominator:

  Raster percentage denominator: `"classified"`, `"non_na"`, or
  `"mask"`. The first two are equivalent for a classified raster;
  `"mask"` uses `analysis_mask` area.

- analysis_mask:

  Optional raster mask.

## Value

An ordinary data frame.

## See also

[`compare_mesohabitat()`](https://el-cordero.github.io/hydromeso/reference/compare_mesohabitat.md)
