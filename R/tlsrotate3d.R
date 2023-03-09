#'Rotate TLS-derived 3D Point Clouds
#'
#'@description This function rotates TLS-derived 3D Point Clouds
#'
#'@param las An object of class LAS [lidR::readLAS()].
##'@param theta Numeric defining the angle in degrees (from 0 to 360) for rotating the 3d point cloud.
#'@param by Character defining the rotation around x ('x'), y ('y') or z ('z') axis. Default: around z-axis.
#'@param scale if TRUE, the xyz coordinates will be scaled to local coordinates by subtracting their values to their
#'corresponding minimum values (e.g. x - min(x). Default is TRUE.
#'
#'@return Returns an object of class LAS containing the rotated 3d point cloud.
#'
#'
#'@examples
#'\donttest{
#'# Path to las file
#'lasfile <- system.file("extdata", "tree_c1.laz", package="rTLsDeep")
#'
#'# Reading las file
#'las<-lidR::readLAS(lasfile)
#'
#'# Visualizing las file
#'suppressWarnings(lidR::plot(las))
#'
#'# Rotating 3d point cloud around Z-axis
#'lasr<-tlsrotate3d(las,theta=180, by="x", scale=TRUE)
#'
#'# Visualizing rotated las file
#'suppressWarnings(lidR::plot(lasr))
#'
#'if (!rgl::rgl.useNULL())
#'  rgl::play3d(rgl::spin3d(axis = c(0, 0, 1), rpm = 5), duration = 10)
#'
#'}
#'@importFrom rgl rotate3d
#'@export
tlsrotate3d<-function(las,theta, by="z",scale=TRUE) {

  if (!by %in% c("x","y","z")) {stop("The by parameter is invalid. It should be defined as 'x', 'y' or 'z'")}

  if (scale==TRUE){
    las@data$X<-las@data$X-min(las@data$X, na.rm=TRUE)
    las@data$Y<-las@data$Y-min(las@data$Y, na.rm=TRUE)
    las@data$Z<-las@data$Z-min(las@data$Z, na.rm=TRUE)
  }
    #Around X-axis:
  if (by=="x"){
  #X = x;
    # las@data$Y = las@data$Y*cos(pi*theta/180) - las@data$Z*sin(pi*theta/180);
    # las@data$Z = las@data$Y*sin(pi*theta/180) + las@data$Z*cos(pi*theta/180);

    lasr<-rgl::rotate3d(as.matrix(las@data[,c(1:3)]), (pi/180)*theta, 1,0,0)


  }
    #Around Y-axis:
  if (by=="y"){

    lasr<-rgl::rotate3d(as.matrix(las@data[,c(1:3)]), (pi/180)*theta, 0,1,0)

    # las@data$X = las@data$X*cos(pi*theta/180) + las@data$Z*sin(pi*theta/180);
    # #Y = y;
    # las@data$Z = las@data$Z*cos(pi*theta/180) - las@data$X*sin(pi*theta/180);
  }
    #Around Z-axis:

  if (by=="z"){

    lasr<-rgl::rotate3d(as.matrix(las@data[,c(1:3)]), (pi/180)*theta, 0,0,1)

      # las@data$X<-las@data$X*cos(pi*theta/180) - las@data$Y*sin(pi*theta/180);
      # las@data$Y<-las@data$X*sin(pi*theta/180) + las@data$Y*cos(pi*theta/180);
      #Z = z;
    }

  las@data$X<-lasr[,1]
  las@data$Y<-lasr[,2]
  las@data$Z<-lasr[,3]

  return(las)
}

