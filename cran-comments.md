## R CMD check results

Tested with R 4.5.3 on macOS Tahoe 26.2 (aarch64):

* `R CMD check`: 0 errors, 0 warnings, 0 notes.
* `R CMD check --as-cran`: 0 errors, 0 warnings, 2 notes locally.

The CRAN incoming note is the expected “New submission” note. The other local
note reports that the macOS-provided HTML Tidy executable is not recent enough
to validate the generated HTML manual. The HTML manual is generated
successfully, and this tooling note is not caused by package content. No
avoidable package notes remain.

## Notes

This is a new submission. The package has no compiled code and its only
non-base runtime dependency is `terra`.
