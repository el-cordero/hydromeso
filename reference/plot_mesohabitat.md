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

- ...:

  Additional plotting arguments.

## Value

`x`, invisibly.
