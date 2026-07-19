## R CMD check results

Tested with R 4.5.3 on macOS Tahoe 26.2 (aarch64):

* `R CMD check`: 0 errors, 0 warnings, 0 notes.
* `R CMD check --as-cran`: 0 errors, 0 warnings, 1 note.

The sole CRAN incoming note is the expected “New submission” note. No
avoidable notes remain.

## Notes

This is a new submission. The package has no compiled code and its only
non-base runtime dependency is `terra`.
