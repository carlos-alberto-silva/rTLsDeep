#'Grid snapshot
#'
#'@description This function captures a 2D grid snapshot of the TLS-derived 3D Point Cloud
#'
#'@param las An object of class LAS [lidR::readLAS()].
#'@param res Numeric defining the resolution or grid cell size of the 2D image.
#'@param by Character defining the grid snapshot view: 'xz', 'yx' or 'xy'. Default: 'xz'.
#'@param func formula defining the equation to be passed in each grid. Default: ~list(Z = max(Z)).
#'@param scale if TRUE, the xyz coordinates will be scaled to local coordinates by subtracting their values to their
#'corresponding minimum values (e.g. x - min(x). Default is TRUE.
#'
#'@return Returns an object of class SpatRaste containing the 2D grid snapshot of the TLS 3D point cloud.
#'
#'
#'@examples
#'#Loading lidR and viridis libraries
#'library(lidR)
#'library(viridis)
#'
#'# Path to las file
#'lasfile <- system.file("extdata", "tree_c1.laz", package="rTLsDeep")
#'
#'# Reading las file
#'las<-readLAS(lasfile)
#'
#'# Visualizing las file
#'suppressWarnings(plot(las))
#'
#'# Creating a 2D grid snapshot
#'func = ~list(Z = max(Z))
#'by="xz"
#'res=0.05
#'scale=TRUE
#'
#'g<-getTLS2D(las, res=res, by=by, func = func, scale=scale)
#'
#'# Visualizing 2D grid snapshot
#'plot(g, asp=TRUE, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="")
#'
#'# Exporting 2D grid snapshot as png file
#'output_png = paste0(tempfile(), '.png')
#'png(output_png, units="px", width=1500, height=1500)
#'terra::image(g, col=viridis::viridis(100))
#'
#'dev.off()
#'@importFrom lidR pixel_metrics
#'@export
getTLS2D<-function(las, res=0.05, by="xz", func = ~list(Z = max(Z)), scale=TRUE) {

  if (!by %in% c("xz","yz","xy")) {stop("The by parameter is invalid. It should be defined as 'xz', 'yz' or 'xy'")}



  if (by=="xz"){ las@data$Y<-las@data$Z}
  if (by=="yz"){ las@data$X<-las@data$Y
                las@data$Y<-las@data$Z}


  if (scale==TRUE){
    las@data$X<-las@data$X-min(las@data$X, na.rm=T)
    las@data$Y<-las@data$Y-min(las@data$Y, na.rm=T)
    las@data$Z<-las@data$Z-min(las@data$Z, na.rm=T)
  }

  grid<-lidR::pixel_metrics(las, func, res =res)
  return(grid)
}



