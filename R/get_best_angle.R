#' Rotating calipers algorithm
#'
#' @description
#' Calculates the minimum oriented bounding box using the
#' rotating calipers algorithm.
#'
#' @param hull A matrix of xy values from a convex hull from which
#' will calculate the minimum oriented bounding box.
#'
getMinBBox <- function(hull) {
  stopifnot(is.matrix(hull), is.numeric(hull), nrow(hull) >= 2, ncol(hull) == 2)

  colnames(hull) = NULL

  ## rotating calipers algorithm using the convex hull
  ## unit basis vectors for all subspaces spanned by the hull edges
  n <- nrow(hull) ## number of hull vertices
  hDir <- diff(rbind(hull, hull[1, ])) ## hull vertices are circular
  hLens <- sqrt(rowSums(hDir^2)) ## length of basis vectors
  huDir <- diag(1 / hLens) %*% hDir ## scaled to unit length

  ## unit basis vectors for the orthogonal subspaces
  ## rotation by 90 deg -> y' = x, x' = -y
  ouDir <- cbind(-huDir[, 2], huDir[, 1])

  ## project hull vertices on the subspaces spanned by the hull edges, and on
  ## the subspaces spanned by their orthogonal complements - in subspace coords
  projHu <- huDir %*% t(hull)
  projOu <- ouDir %*% t(hull)

  ## range of projections and corresponding width/height of bounding rectangle
  rangeH <- matrix(numeric(n * 2), ncol = 2) ## hull edge
  rangeO <- matrix(numeric(n * 2), ncol = 2) ## orthogonal subspace
  widths <- numeric(n)
  heights <- numeric(n)

  rangeH = matrixStats::rowRanges(projHu)
  rangeO = matrixStats::rowRanges(projOu)
  widths = matrixStats::rowDiffs(rangeH)
  heights = matrixStats::rowDiffs(rangeO)

  ## extreme projections for min-area rect in subspace coordinates
  ## hull edge leading to minimum-area
  eMin <- which.min(widths * heights)
  hProj <- rbind(rangeH[eMin, ], 0)
  oProj <- rbind(0, rangeO[eMin, ])

  ## move projections to rectangle corners
  hPts <- rbind(hProj[1,], oProj[2,1])
  oPts <- rbind(hProj[1,], oProj[2,2])

  ## corners in standard coordinates, rows = x,y, columns = corners
  ## in combined (4x2)-matrix: reverse point order to be usable in polygon()
  ## basis formed by hull edge and orthogonal subspace
  basis <- cbind(huDir[eMin, ], ouDir[eMin, ])
  hCorn <- basis %*% hPts
  oCorn <- basis %*% oPts
  pts <- t(cbind(hCorn, oCorn[, c(2, 1)]))

  ## angle of longer edge pointing up
  dPts <- diff(pts)
  e <- dPts[which.max(rowSums(dPts^2)), ] ## one of the longer edges
  eUp <- e * sign(e[2]) ## rotate upwards 180 deg if necessary
  deg <- atan2(eUp[2], eUp[1]) * 180 / pi ## angle in degrees

  return(deg)
}

#' Get best angle for plotting the tree
#'
#' @description
#' Calculates the minimum oriented bounding box using the
#' rotating calipers algorithm and extracts the angle
#'
#' @param las An object of class LAS [lidR::readLAS()].
#'
#' @return Returns a list containing the model object with the required parameters and model_type used.
#'
#' @examples
#' lasfile <- system.file("extdata", "tree_c2.laz", package = "rTLsDeep")
#' las <- lidR::readLAS(lasfile)
#'
#' (get_best_angle(las))
#'
#' @import sf 
#' @export
get_best_angle <- function(las) {
  return(
    getMinBBox(
      sf::st_coordinates(
        las[grDevices::chull(las$X, las$Y)],
        z = FALSE
      )
    )
  )
}
