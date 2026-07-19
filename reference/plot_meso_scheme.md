# Plot a mesohabitat classification scheme

Plot a mesohabitat classification scheme

## Usage

``` r
plot_meso_scheme(
  scheme = meso_scheme_default(),
  xlim = NULL,
  ylim = NULL,
  reverse_depth_axis = FALSE,
  palette = mesohabitat_palette(scheme),
  ...
)
```

## Arguments

- scheme:

  A `meso_scheme`.

- xlim, ylim:

  Optional finite velocity and depth limits.

- reverse_depth_axis:

  Reverse the displayed depth axis only when `TRUE`.

- palette:

  Named class colors.

- ...:

  Additional arguments passed to
  [`graphics::plot.default()`](https://rdrr.io/r/graphics/plot.default.html).

## Value

The scheme, invisibly.
