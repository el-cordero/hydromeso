Big Blue-Kansas Rivers HEC-RAS example
======================================

These depth and velocity GeoTIFFs are a compact derivative of the 31 May 2022
HEC-RAS model output used by Cordero and Harris (Preprint). They show the
confluence of the Big Blue and Kansas Rivers near Manhattan, Kansas, USA.

The package sample was cropped to the detailed manuscript-map extent
(-96.542 to -96.514 longitude, 39.181 to 39.192 latitude), aggregated from
3-foot to 18-foot cells using the mean of available values, and converted from
feet and feet per second to metres and metres per second. The original rasters
did not embed a CRS; the CRS recorded here is the source project's documented
NAD 1983 (CORS96) StatePlane Kansas North coordinate system in US survey feet.

The source project is not modified by the package data-generation workflow.
