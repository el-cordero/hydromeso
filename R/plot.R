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
#' @param legend Show one shared legend below the plot or plot panels.
#' @param legend_ncol Number of columns in the shared legend.
#' @param legend_cex Legend text size multiplier.
#' @param ... Additional plotting arguments.
#' @return `x`, invisibly.
#' @export
plot_mesohabitat <- function(x, depth_col = "depth", velocity_col = "velocity",
                             class_col = "mesohabitat_class", label_col = "mesohabitat",
                             scheme = .scheme_from_object(x),
                             palette = mesohabitat_palette(scheme),
                             legend = TRUE, legend_ncol = 4, legend_cex = 0.75,
                             ...) {
  if (!is.logical(legend) || length(legend) != 1L || is.na(legend)) {
    stop("`legend` must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.numeric(legend_ncol) || length(legend_ncol) != 1L ||
      is.na(legend_ncol) || legend_ncol < 1 || legend_ncol %% 1 != 0) {
    stop("`legend_ncol` must be a positive integer.", call. = FALSE)
  }
  if (!is.numeric(legend_cex) || length(legend_cex) != 1L ||
      is.na(legend_cex) || legend_cex <= 0) {
    stop("`legend_cex` must be a positive number.", call. = FALSE)
  }
  legend_ncol <- min(as.integer(legend_ncol), length(palette))
  legend_rows <- ceiling(length(palette) / legend_ncol)
  legend_height <- 0.12 + 0.10 * legend_rows
  draw_legend <- function() {
    graphics::par(mar = rep(0.2, 4))
    graphics::plot.new()
    graphics::legend(
      "center", legend = names(palette), fill = unname(palette),
      ncol = legend_ncol, cex = legend_cex, bty = "n", xpd = NA
    )
  }
  draw_single_with_legend <- function(draw) {
    if (!legend) return(draw())
    old_par <- graphics::par(no.readonly = TRUE)
    on.exit({
      graphics::layout(1)
      graphics::par(old_par)
    }, add = TRUE)
    graphics::layout(
      matrix(c(1, 2), nrow = 2), heights = c(1, legend_height)
    )
    draw()
    draw_legend()
    invisible(NULL)
  }
  if (inherits(x, "SpatRaster")) {
    if (!legend) {
      terra::plot(x, col = unname(palette), legend = FALSE, ...)
    } else {
      dots <- list(...)
      layer_count <- terra::nlyr(x)
      panel_ncol <- ceiling(sqrt(layer_count))
      panel_nrow <- ceiling(layer_count / panel_ncol)
      panel_ids <- matrix(
        seq_len(panel_nrow * panel_ncol), nrow = panel_nrow, byrow = TRUE
      )
      panel_ids[panel_ids > layer_count] <- 0
      layout_matrix <- rbind(
        panel_ids, rep(layer_count + 1L, panel_ncol)
      )
      old_par <- graphics::par(no.readonly = TRUE)
      on.exit({
        graphics::layout(1)
        graphics::par(old_par)
      }, add = TRUE)
      graphics::layout(
        layout_matrix,
        heights = c(rep(1, panel_nrow), legend_height)
      )
      if (is.null(dots$main)) {
        panel_titles <- if (layer_count == 1L) "" else names(x)
      } else {
        panel_titles <- rep_len(dots$main, layer_count)
        dots$main <- NULL
      }
      dots$nc <- dots$nr <- dots$maxnl <- NULL
      for (i in seq_len(layer_count)) {
        do.call(
          terra::plot,
          c(list(x = x[[i]], col = unname(palette), legend = FALSE,
                 main = panel_titles[i]), dots)
        )
      }
      draw_legend()
    }
  } else if (inherits(x, "SpatVector")) {
    ids <- x[[class_col]][, 1]
    draw_single_with_legend(function() {
      terra::plot(
        x, col = unname(palette[match(ids, scheme$rules$class_id)]), ...
      )
    })
  } else if (is.data.frame(x)) {
    if (!all(c(depth_col, velocity_col, class_col) %in% names(x))) stop("Required plotting columns are missing.", call. = FALSE)
    cols <- unname(palette[match(x[[class_col]], scheme$rules$class_id)])
    draw_single_with_legend(function() {
      graphics::plot(
        x[[velocity_col]], x[[depth_col]], col = cols, pch = 19,
        xlab = paste0("Velocity (", scheme$velocity_units, ")"),
        ylab = paste0("Depth (", scheme$depth_units, ")"), ...
      )
    })
  } else stop("Unsupported object type for plotting.", call. = FALSE)
  invisible(x)
}
