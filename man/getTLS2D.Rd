% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getTLS2D.R
\name{getTLS2D}
\alias{getTLS2D}
\title{Grid snapshot}
\usage{
getTLS2D(las, res = 0.05, by = "xz", func = ~list(Z = max(Z)), scale = TRUE)
}
\arguments{
\item{las}{An object of class LAS [lidR::readLAS()].}

\item{res}{Numeric defining the resolution or grid cell size of the 2D image.}

\item{by}{Character defining the grid snapshot view: 'xz', 'yx' or 'xy'. Default: 'xz'.}

\item{func}{formula defining the equation to be passed in each grid. Default: ~list(Z = max(Z)).}

\item{scale}{if TRUE, the xyz coordinates will be scaled to local coordinates by subtracting their values to their
corresponding minimum values (e.g. x - min(x). Default is TRUE.}
}
\value{
Returns an object of class SpatRaste containing the 2D grid snapshot of the TLS 3D point cloud.
}
\description{
This function captures a 2D grid snapshot of the TLS-derived 3D Point Cloud
}
\examples{
#Loading lidR and viridis libraries
library(lidR)
library(viridis)

# Path to las file
lasfile <- system.file("extdata", "tree_c1.laz", package="rTLsDeep")

# Reading las file
las<-readLAS(lasfile)

# Visualizing las file
suppressWarnings(plot(las))

# Creating a 2D grid snapshot
func = ~list(Z = max(Z))
by="xz"
res=0.05
scale=TRUE

g<-getTLS2D(las, res=res, by=by, func = func, scale=scale)

# Visualizing 2D grid snapshot
plot(g, asp=TRUE, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="")

# Exporting 2D grid snapshot as png file
output_png = paste0(tempfile(), '.png')
png(output_png, units="px", width=1500, height=1500)
terra::image(g, col=viridis::viridis(100))

dev.off()
}
