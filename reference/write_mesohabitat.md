# Write classified mesohabitat output

Dispatches to a categorical GeoTIFF or other raster format, a `terra`
vector format, or CSV. Shapefile output uses short safe class field
names to avoid silent truncation.

## Usage

``` r
write_mesohabitat(
  x,
  filename,
  overwrite = FALSE,
  sidecar = TRUE,
  create_dir = FALSE,
  scheme = .scheme_from_object(x),
  ...
)
```

## Arguments

- x:

  A classified data frame, `SpatVector`, or `SpatRaster`.

- filename:

  Output path.

- overwrite:

  Permit replacement.

- sidecar:

  Write a CSV class table beside the output.

- create_dir:

  Create missing parent directories only when `TRUE`.

- scheme:

  A `meso_scheme` used for the sidecar.

- ...:

  Format-specific writer arguments.

## Value

The normalized output path, invisibly.
