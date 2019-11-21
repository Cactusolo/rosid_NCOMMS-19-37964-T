plotRateThroughTime2 <- function (rmat, useMedian = TRUE, intervals = seq(from = 0, to = 1, 
                                                  by = 0.01), ratetype = "auto", nBins = 100, smooth = FALSE, 
          smoothParam = 0.2, opacity = 0.01, intervalCol = "blue", 
          avgCol = "red", start.time = NULL, end.time = NULL, node = NULL, 
          nodetype = "include", plot = TRUE, cex.axis = 1, cex.lab = 1.3, 
          lwd = 3, xline = 3.5, yline = 3.5, mar = c(6, 6, 1, 1), xticks = NULL, 
          yticks = NULL, xlim = "auto", ylim = "auto", add = FALSE, 
          axis.labels = TRUE) 
{
  if (!is.logical(useMedian)) {
    stop("ERROR: useMedian must be either TRUE or FALSE.")
  }
  if (!any(c("numeric", "NULL") %in% class(intervals))) {
    stop("ERROR: intervals must be either 'NULL' or a vector of quantiles.")
  }
  if (!is.logical(smooth)) {
    stop("ERROR: smooth must be either TRUE or FALSE.")
  }
  if (ratetype == "speciation") {
    ratetype <- "auto"
  }
  if (ratetype != "auto" & ratetype != "extinction" & ratetype != 
      "netdiv") {
    stop("ERROR: ratetype must be 'auto', 'extinction', or 'netdiv'.\n")
  }
  if (ratetype == "auto" & rmat$type == "diversification") {
    rate <- rmat$lambda
    ratelabel <- "speciation rate"
  }
  if (ratetype == "extinction") {
    rate <- rmat$mu
    ratelabel <- "extinction rate"
  }
  if (ratetype == "netdiv") {
    rate <- rmat$lambda - rmat$mu
    ratelabel <- "Net diversification rate"
  }
  maxTime <- max(rmat$times)
  nanCol <- apply(rate, 2, function(x) any(is.nan(x)))
  rate <- rate[, which(nanCol == FALSE)]
  rmat$times <- rmat$times[which(nanCol == FALSE)]
  rmat$times <- max(rmat$times) - rmat$times
  if (!is.null(intervals)) {
    mm <- apply(rate, MARGIN = 2, quantile, intervals)
    poly <- list()
    q1 <- 1
    q2 <- nrow(mm)
    repeat {
      if (q1 >= q2) {
        break
      }
      a <- as.data.frame(cbind(rmat$times, mm[q1, ]))
      b <- as.data.frame(cbind(rmat$times, mm[q2, ]))
      b <- b[rev(rownames(b)), ]
      colnames(a) <- colnames(b) <- c("x", "y")
      poly[[q1]] <- rbind(a, b)
      q1 <- q1 + 1
      q2 <- q2 - 1
    }
  }
  if (!useMedian) {
    avg <- colMeans(rate)
  }
  else {
    avg <- unlist(apply(rate, 2, median))
  }
  if (smooth) {
    for (i in 1:length(poly)) {
      p <- poly[[i]]
      rows <- nrow(p)
      p[1:rows/2, 2] <- loess(p[1:rows/2, 2] ~ p[1:rows/2, 
                                                 1], span = smoothParam)$fitted
      p[(rows/2):rows, 2] <- loess(p[(rows/2):rows, 2] ~ 
                                     p[(rows/2):rows, 1], span = smoothParam)$fitted
      poly[[i]] <- p
    }
    avg <- loess(avg ~ rmat$time, span = smoothParam)$fitted
  }
  if (plot) {
    if (!add) {
      plot.new()
      par(mar = mar)
      if (unique(xlim == "auto") & unique(ylim == "auto")) {
        xMin <- maxTime
        xMax <- 0
        if (!is.null(intervals)) {
          yMin <- min(poly[[1]][, 2])
          yMax <- max(poly[[1]][, 2])
        }
        else {
          yMin <- min(avg)
          yMax <- max(avg)
        }
        if (yMin >= 0) {
          yMin <- 0
        }
      }
      if (unique(xlim != "auto") & unique(ylim == "auto")) {
        xMin <- xlim[1]
        xMax <- xlim[2]
        if (!is.null(intervals)) {
          yMin <- min(poly[[1]][, 2])
          yMax <- max(poly[[1]][, 2])
        }
        else {
          yMin <- min(avg)
          yMax <- max(avg)
        }
        if (yMin >= 0) {
          yMin <- 0
        }
      }
      if (unique(xlim == "auto") & unique(ylim != "auto")) {
        xMin <- maxTime
        xMax <- 0
        yMin <- ylim[1]
        yMax <- ylim[2]
      }
      if (unique(xlim != "auto") & unique(ylim != "auto")) {
        xMin <- xlim[1]
        xMax <- xlim[2]
        yMin <- ylim[1]
        yMax <- ylim[2]
      }
      plot.window(xlim = c(xMin, xMax), ylim = c(yMin, 
                                                 yMax))
      if (is.null(xticks)) {
        axis(at = c(round(1.2 * xMin), axTicks(1)), cex.axis = cex.axis, 
             side = 1)
      }
      if (!is.null(xticks)) {
        axis(at = c(1.2 * xMin, seq(xMin, xMax, length.out = xticks + 
                                      1)), labels = c(1.2 * xMin, signif(seq(xMin, 
                                                                             xMax, length.out = xticks + 1), digits = 2)), 
             cex.axis = cex.axis, side = 1)
      }
      if (is.null(yticks)) {
        axis(at = c(-1, axTicks(2)), cex.axis = cex.axis, 
             las = 1, side = 2)
      }
      if (!is.null(yticks)) {
        axis(at = c(-0.2, seq(yMin, 1.2 * yMax, length.out = yticks + 
                                1)), labels = c(-0.2, signif(seq(yMin, 1.2 * 
                                                                   yMax, length.out = yticks + 1), digits = 2)), 
             las = 1, cex.axis = cex.axis, side = 2)
      }
      if (axis.labels) {
        mtext(side = 1, text = "Time before present (Myr)", 
              line = xline, cex = cex.lab)
        mtext(side = 2, text = ratelabel, line = yline, 
              cex = cex.lab)
      }
    }
    if (!is.null(intervals)) {
      for (i in 1:length(poly)) {
        polygon(x = poly[[i]][, 1], y = poly[[i]][, 2], 
                col = transparentColor(intervalCol, opacity), 
                border = NA)
      }
    }
    lines(x = rmat$time, y = avg, lwd = lwd, col = avgCol)
  }
  else {
    return(list(poly = poly, avg = avg, times = rmat$time))
  }
}