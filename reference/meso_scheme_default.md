# Default eight-class fluvial mesohabitat scheme

Returns the exact depth-velocity classification used by Cordero and
Harris (Preprint). The broader depth-velocity framework is informed by
Aadland (1993), whose paper describes six habitat types and should not
be read as the source of the two added high-velocity class names. Inputs
must be metres and metres per second unless explicitly converted before
classification.

## Usage

``` r
meso_scheme_default()
```

## Value

A validated `meso_scheme` with eight nominal classes.

## References

Cordero, E. and Harris, A. (Preprint). *Semi-Supervised and Supervised
Machine Learning Approaches to Predicting Fluvial Mesohabitats from
Satellite Data*. SSRN.
[doi:10.2139/ssrn.7100727](https://doi.org/10.2139/ssrn.7100727) .

Aadland, L. P. (1993). Stream Habitat Types: Their Fish Assemblages and
Relationship to Flow. *North American Journal of Fisheries Management*,
13, 790-806.
[doi:10.1577/1548-8675(1993)013\<0790:SHTTFA\>2.3.CO;2](https://doi.org/10.1577/1548-8675%281993%29013%3C0790%3ASHTTFA%3E2.3.CO%3B2)
.

## See also

[`meso_scheme()`](https://el-cordero.github.io/hydromeso/reference/meso_scheme.md),
[`plot_meso_scheme()`](https://el-cordero.github.io/hydromeso/reference/plot_meso_scheme.md)

## Examples

``` r
meso_scheme_default()
```
