# Scientific basis and interpretation

The default eight-class scheme implements the depth and velocity
thresholds used by Cordero and Harris ([Cordero and Harris
2026](#ref-cordero2026)), with the broader depth-velocity mesohabitat
framework informed by Aadland (1993) ([Aadland 1993](#ref-aadland1993)).
Cordero and Harris define the exact eight rows implemented by the
package, including “Faster than Raceway” and “Faster than Deep Pool.”

Aadland studied fish assemblages, habitat-use and habitat-preference
guilds, and habitat relationships with flow in six Minnesota streams.
The original paper describes six types: shallow pool, slow riffle, fast
riffle, raceway, medium pool, and deep pool. It does not present the
package’s exact eight-row SI table, and the package does not attribute
the two added high-velocity labels to Aadland.

The output is a hydraulic classification based on depth and velocity
alone. It does not establish habitat quality or species occupancy.
Biological interpretation can depend on species, life stage, stream
type, substrate, cover, connectivity, water quality, temperature, flow
regime, and local field validation. Raster results also inherit
hydraulic-model, terrain, boundary condition, calibration, and
resolution uncertainty. Alignment or interpolation can move cells across
sharp class thresholds.

Users must document how dry cells are encoded. The default
`dry_threshold = NULL` preserves the mathematical scheme, including
Class 1 for zero depth and zero velocity. Classifying median hydraulic
surfaces is not the same as taking the modal class through time. Class
IDs are identifiers, not ecological ranks.

## References

Aadland, Luther P. 1993. “Stream Habitat Types: Their Fish Assemblages
and Relationship to Flow.” *North American Journal of Fisheries
Management* 13 (4): 790–806.
<https://doi.org/10.1577/1548-8675(1993)013%3C0790:SHTTFA%3E2.3.CO;2>.

Cordero, Elvin, and Aubrey Harris. 2026. “Semi-Supervised and Supervised
Machine Learning Approaches to Predicting Fluvial Mesohabitats from
Satellite Data.” <https://doi.org/10.2139/ssrn.7100727>.
