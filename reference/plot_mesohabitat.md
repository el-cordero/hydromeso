# Plot classified mesohabitat output

Plot classified mesohabitat output

## Usage

``` r
plot_mesohabitat(
  x,
  depth_col = "depth",
  velocity_col = "velocity",
  class_col = "mesohabitat_class",
  label_col = "mesohabitat",
  scheme = .scheme_from_object(x),
  palette = mesohabitat_palette(scheme),
  legend = TRUE,
  legend_ncol = 4,
  legend_cex = 0.75,
  ...
)
```

## Arguments

- x:

  A classified table, `SpatVector`, or `SpatRaster`.

- depth_col, velocity_col:

  Table columns for depth and velocity.

- class_col, label_col:

  Classification columns.

- scheme:

  A `meso_scheme`.

- palette:

  Named colors.

- legend:

  Show one shared legend below the plot or plot panels.

- legend_ncol:

  Number of columns in the shared legend.

- legend_cex:

  Legend text size multiplier.

- ...:

  Additional plotting arguments.

## Value

`x`, invisibly.
