#' Stable mesohabitat class colors
#'
#' @param scheme A `meso_scheme`.
#' @return A named character vector keyed by class label.
#' @export
mesohabitat_palette <- function(scheme = meso_scheme_default()) {
  scheme <- .check_scheme(scheme)
  base <- c("#56B4E9", "#0072B2", "#003B73", "#A6D854",
            "#1B9E77", "#E6AB02", "#D95F02", "#7570B3")
  cols <- if (nrow(scheme$rules) <= length(base)) base[seq_len(nrow(scheme$rules))] else
    grDevices::hcl.colors(nrow(scheme$rules), "Dark 3")
  stats::setNames(cols, scheme$rules$label)
}

#' Plot a mesohabitat classification scheme
#'
#' @param scheme A `meso_scheme`.
#' @param xlim,ylim Optional finite velocity and depth limits.
#' @param reverse_depth_axis Reverse the displayed depth axis only when `TRUE`.
#' @param palette Named class colors.
#' @param ... Additional arguments passed to [graphics::plot.default()].
#' @return The scheme, invisibly.
#' @export
plot_meso_scheme <- function(scheme = meso_scheme_default(), xlim = NULL,
                             ylim = NULL, reverse_depth_axis = FALSE,
                             palette = mesohabitat_palette(scheme), ...) {
  scheme <- .check_scheme(scheme); r <- scheme$rules
  auto_limit <- function(z) {
    finite <- z[is.finite(z)]; m <- max(finite)
    c(0, m + max(0.2, m * 0.35))
  }
  if (is.null(xlim)) xlim <- auto_limit(c(r$velocity_min, r$velocity_max))
  if (is.null(ylim)) ylim <- auto_limit(c(r$depth_min, r$depth_max))
  yplot <- if (reverse_depth_axis) rev(ylim) else ylim
  graphics::plot(NA, xlim = xlim, ylim = yplot,
                 xlab = paste0("Velocity (", scheme$velocity_units, ")"),
                 ylab = paste0("Depth (", scheme$depth_units, ")"), ...)
  for (i in seq_len(nrow(r))) {
    x1 <- max(r$velocity_min[i], min(xlim)); x2 <- min(r$velocity_max[i], max(xlim))
    y1 <- max(r$depth_min[i], min(ylim)); y2 <- min(r$depth_max[i], max(ylim))
    if (x1 < x2 && y1 < y2) {
      graphics::rect(x1, y1, x2, y2, col = palette[r$label[i]], border = "white")
      graphics::text(mean(c(x1, x2)), mean(c(y1, y2)), r$label[i], cex = 0.7)
    }
  }
  graphics::box()
  invisible(scheme)
}

#' Plot classified mesohabitat output
#'
#' @param x A classified table, `SpatVector`, or `SpatRaster`.
#' @param depth_col,velocity_col Table columns for depth and velocity.
#' @param class_col,label_col Classification columns.
#' @param scheme A `meso_scheme`.
#' @param palette Named colors.
#' @param ... Additional plotting arguments.
#' @return `x`, invisibly.
#' @export
plot_mesohabitat <- function(x, depth_col = "depth", velocity_col = "velocity",
                             class_col = "mesohabitat_class", label_col = "mesohabitat",
                             scheme = .scheme_from_object(x),
                             palette = mesohabitat_palette(scheme), ...) {
  if (inherits(x, "SpatRaster")) {
    terra::plot(x, col = unname(palette), ...)
  } else if (inherits(x, "SpatVector")) {
    ids <- x[[class_col]][, 1]
    terra::plot(x, col = unname(palette[match(ids, scheme$rules$class_id)]), ...)
    graphics::legend("topright", legend = names(palette), fill = palette, cex = 0.7)
  } else if (is.data.frame(x)) {
    if (!all(c(depth_col, velocity_col, class_col) %in% names(x))) stop("Required plotting columns are missing.", call. = FALSE)
    cols <- unname(palette[match(x[[class_col]], scheme$rules$class_id)])
    graphics::plot(x[[velocity_col]], x[[depth_col]], col = cols, pch = 19,
                   xlab = paste0("Velocity (", scheme$velocity_units, ")"),
                   ylab = paste0("Depth (", scheme$depth_units, ")"), ...)
    graphics::legend("topright", legend = names(palette), col = palette, pch = 19, cex = 0.7)
  } else stop("Unsupported object type for plotting.", call. = FALSE)
  invisible(x)
}

