#' Rotating calipers algorithm
#'
#' @description
#' Calculates the minimum oriented bounding box using the
#' rotating calipers algorithm.
#' Credits go to Daniel Wollschlaeger <https://github.com/ramnathv>
#'
#' @param xy A matrix of xy values from which to calculate the minimum oriented
#' bounding box.
#'
#' @importFrom grDevices chull
getMinBBox <- function(xy) {
  stopifnot(is.matrix(xy), is.numeric(xy), nrow(xy) >= 2, ncol(xy) == 2)

  ## rotating calipers algorithm using the convex hull
  H    <- grDevices::chull(xy)      ## hull indices, vertices ordered clockwise
  n    <- length(H)      ## number of hull vertices
  hull <- xy[H, ]        ## hull vertices

  ## unit basis vectors for all subspaces spanned by the hull edges
  hDir  <- diff(rbind(hull, hull[1, ])) ## hull vertices are circular
  hLens <- sqrt(rowSums(hDir^2))        ## length of basis vectors
  huDir <- diag(1/hLens) %*% hDir       ## scaled to unit length

  ## unit basis vectors for the orthogonal subspaces
  ## rotation by 90 deg -> y' = x, x' = -y
  ouDir <- cbind(-huDir[ , 2], huDir[ , 1])

  ## project hull vertices on the subspaces spanned by the hull edges, and on
  ## the subspaces spanned by their orthogonal complements - in subspace coords
  projMat <- rbind(huDir, ouDir) %*% t(hull)

  ## range of projections and corresponding width/height of bounding rectangle
  rangeH  <- matrix(numeric(n*2), ncol=2)  ## hull edge
  rangeO  <- matrix(numeric(n*2), ncol=2)  ## orthogonal subspace
  widths  <- numeric(n)
  heights <- numeric(n)

  for(i in seq(along=numeric(n))) {
    rangeH[i, ] <- range(projMat[  i, ])

    ## the orthogonal subspace is in the 2nd half of the matrix
    rangeO[i, ] <- range(projMat[n+i, ])
    widths[i]   <- abs(diff(rangeH[i, ]))
    heights[i]  <- abs(diff(rangeO[i, ]))
  }

  ## extreme projections for min-area rect in subspace coordinates
  ## hull edge leading to minimum-area
  eMin  <- which.min(widths*heights)
  hProj <- rbind(   rangeH[eMin, ], 0)
  oProj <- rbind(0, rangeO[eMin, ])

  ## move projections to rectangle corners
  hPts <- sweep(hProj, 1, oProj[ , 1], "+")
  oPts <- sweep(hProj, 1, oProj[ , 2], "+")

  ## corners in standard coordinates, rows = x,y, columns = corners
  ## in combined (4x2)-matrix: reverse point order to be usable in polygon()
  ## basis formed by hull edge and orthogonal subspace
  basis <- cbind(huDir[eMin, ], ouDir[eMin, ])
  hCorn <- basis %*% hPts
  oCorn <- basis %*% oPts
  pts   <- t(cbind(hCorn, oCorn[ , c(2, 1)]))

  ## angle of longer edge pointing up
  dPts <- diff(pts)
  e    <- dPts[which.max(rowSums(dPts^2)), ] ## one of the longer edges
  eUp  <- e * sign(e[2])       ## rotate upwards 180 deg if necessary
  deg  <- atan2(eUp[2], eUp[1])*180 / pi     ## angle in degrees

  return(list(pts=pts, width=heights[eMin], height=widths[eMin], angle=deg))
}

#' Get best angle for plotting the tree
#'
#' @description
#' Calculates the minimum oriented bounding box using the
#' rotating calipers algorithm and extracts the angle
#' Credits go to Daniel Wollschlaeger <https://github.com/ramnathv>
#'
#' @param las An object of class LAS [lidR::readLAS()].
#'
#' @return Returns a list containing the model object with the required parameters and model_type used.
#'
#' @examples
#' lasfile <- system.file("extdata", "tree_c1.laz", package="rTLsDeep")
#' las<-lidR::readLAS(lasfile)
#' 
#' get_best_angle(las)
#'
#' @import sf
get_best_angle = function(las) {
    return(getMinBBox(sf::st_coordinates(las[chull(las$X, las$Y)], z=FALSE))$angle[[1]])
}