
require(lidR)
require(rgl)

#las<-readLAS("C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c1.laz")
las = readTLSLAS("C:\\Users\\c.silva\\Documents\\rTLsDeep\\readme\\laz\\Tree1_c2.laz", select = "xyzcr", "-filter_with_voxel 0.01")
las = classify_noise(las, ivf(0.25, 5))
las = filter_poi(las, Classification != LASNOISE)
writeLAS(las,"C:\\Users\\c.silva\\Documents\\rTLsDeep\\readme\\laz\\Tree_c2r.laz")

plot(las, bg="white", pal =viridis::viridis(100))

rgl::axes3d(c("x+", "y-", "z-"), col="black")
rgl::grid3d(side=c('x+', 'y-', 'z'), col="gray") # grid
#las<-readLAS("C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c2.laz")
las = readTLSLAS("C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c1.laz", select = "xyzcr", "-filter_with_voxel 0.01")
las = classify_noise(las, ivf(0.25, 5))
las = filter_poi(las, Classification != LASNOISE)
writeLAS(las,"C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c2r.laz")

#las<-readLAS("C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c3.laz")
las = readTLSLAS("C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c3.laz", select = "xyzcr", "-filter_with_voxel 0.01")
las = classify_noise(las, ivf(0.25, 5))
las = filter_poi(las, Classification != LASNOISE)
writeLAS(las,"C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c3r.laz")

#las<-readLAS("C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c4.laz")
las = readTLSLAS("C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c4.laz", select = "xyzcr", "-filter_with_voxel 0.01")
las = classify_noise(las, ivf(0.25, 5))
las = filter_poi(las, Classification != LASNOISE)
writeLAS(las,"C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c4r.laz")
plot(las)

#las<-readLAS("C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c5.laz")
las = readTLSLAS("C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c5.laz", select = "xyzcr", "-filter_with_voxel 0.01")
las = classify_noise(las, ivf(0.25, 5))
las = filter_poi(las, Classification != LASNOISE)
writeLAS(las,"C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c5r.laz")

#las<-readLAS("C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c6.laz")
las = readTLSLAS("C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c6.laz", select = "xyzcr", "-filter_with_voxel 0.01")
las = classify_noise(las, ivf(0.25, 5))
las = filter_poi(las, Classification != LASNOISE)
writeLAS(las,"C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c6r.laz")


outdir="C:\\Users\\c.silva\\Documents\\rTLsDeep\\readme\\laz"


func = ~list(Z = max(Z))
by="xz"
res=0.05
scale=TRUE

# Reading las file for each post-hurricane individual tree-level damage classes
tree_c1<-readLAS(paste0(outdir,"//Tree_c1.laz"))
tree_c2<-readLAS(paste0(outdir,"//Tree_c2.laz"))
tree_c3<-readLAS(paste0(outdir,"//Tree_c3.laz"))
tree_c4<-readLAS(paste0(outdir,"//Tree_c4.laz"))
tree_c5<-readLAS(paste0(outdir,"//Tree_c5.laz"))
tree_c6<-readLAS(paste0(outdir,"//Tree_c6.laz"))

gtree_c1<-getTLS2D(tree_c1, res=0.05, by="xz", func = func, scale=TRUE)
gtree_c2<-getTLS2D(tree_c2, res=0.05, by="xz", func = func, scale=TRUE)
gtree_c3<-getTLS2D(tree_c3, res=0.05, by="xz", func = func, scale=TRUE)
gtree_c4<-getTLS2D(tree_c4, res=0.05, by="xz", func = func, scale=TRUE)
gtree_c5<-getTLS2D(tree_c5, res=0.05, by="xz", func = func, scale=TRUE)
gtree_c6<-getTLS2D(tree_c6, res=0.05, by="yz", func = func, scale=TRUE)

windows()
plot(gtree_c1)
par(mfrow=c(1,6))
# Visualizing 2D grid snapshot

plot(gtree_c1, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,30), main="C1",cex=2)
plot(gtree_c2, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,30), main="C2",cex=2)
plot(gtree_c3, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,30), main="C3",cex=2)
plot(gtree_c4, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,30), main="C4",cex=2)
plot(gtree_c5, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,30), main="C5",cex=2)
plot(gtree_c6, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,30), main="C6",cex=2)

gtree_c6$Z


las60<-tlsrotate3d(las,theta=60, by="z", scale=TRUE)
las120<-tlsrotate3d(las,theta=120, by="z", scale=TRUE)
las180<-tlsrotate3d(las,theta=180, by="z", scale=TRUE)
las240<-tlsrotate3d(las,theta=240, by="z", scale=TRUE)
las300<-tlsrotate3d(las,theta=300, by="z", scale=TRUE)
las360<-tlsrotate3d(las,theta=360, by="z", scale=TRUE)

gtree_60<-getTLS2D(las60, res=0.05, by="xz", func = func, scale=TRUE)
gtree_120<-getTLS2D(las120, res=0.05, by="xz", func = func, scale=TRUE)
gtree_180<-getTLS2D(las180, res=0.05, by="xz", func = func, scale=TRUE)
gtree_240<-getTLS2D(las240, res=0.05, by="xz", func = func, scale=TRUE)
gtree_300<-getTLS2D(las300, res=0.05, by="xz", func = func, scale=TRUE)
gtree_360<-getTLS2D(las360, res=0.05, by="xz", func = func, scale=TRUE)


windows()
plot(gtree_c1)
par(mfrow=c(1,6))
# Visualizing 2D grid snapshot

plot(gtree_60, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,16), main="60º",cex=2)
plot(gtree_120, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,16), main="120º",cex=2)
plot(gtree_180, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,16), main="180º",cex=2)
plot(gtree_240, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,16), main="240º",cex=2)
plot(gtree_300, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,16), main="300º",cex=2)
plot(gtree_360, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,16), main="360º",cex=2)




j<-snapshot2D(las, res=0.05, by="y", func = ~list(Z = max(Z)), scale=FALSE)

LASr<-las
lasr<-rgl::rotate3d(as.matrix(las@data[,c(1:3)]), (pi/180)*30, 0,0,1)

las@data$X<-lasr[,1]
las@data$Y<-lasr[,2]
las@data$Z<-lasr[,3]

head(xxx)
head(las@data)


plot(las)

plot(las)


example(plot3d)
M <- r3dDefaults$userMatrix
fn <- par3dinterp(times = (0:2)*0.75, userMatrix = list(M,
                                                        rotate3d(M, pi/2, 1, 0, 0),
                                                        rotate3d(M, pi/2, 0, 1, 0)),
                  scale = c(0.5, 1, 2))
control <- par3dinterpControl(fn, 0, 3, steps = 15)
control
if (interactive() || in_pkgdown_example())
  rglwidget(width = 500, height = 250) %>%
  playwidget(control,
             step = 0.01, loop = TRUE, rate = 0.5)






las<-readLAS("C:\\Users\\c.silva\\Documents\\rTLsDeep\\inst\\extdata\\Tree_c1.laz")
j<-snapshot2D(las, res=0.05, by="y", func = ~list(Z = max(Z)), scale=FALSE)

class(j)
plot(j)

plot(las)

lasr<-lasrotate3d(las,theta=180, by="x", scale=TRUE)
plot(lasr)

if (!rgl.useNULL())
  rgl::play3d(spin3d(axis = c(0, 0, 1), rpm = 5), duration = 10)


# Spin one object
open3d()
plot3d(oh3d(col = "lightblue", alpha = 0.5))
if (!rgl.useNULL())
  play3d(spin3d(axis = c(0, 0, 1), rpm = 5), duration = 10)


example(plot3d)
M <- r3dDefaults$userMatrix
fn <- par3dinterp(times = (0:1)*0.75, userMatrix = list(M,
                                                        rgl::rotate3d(M, pi/2, 0, 0, 1)),
                  scale = c(0.5, 1))
control <- par3dinterpControl(fn, 0, 3, steps = 15)
control
if (interactive() || in_pkgdown_example())
  rglwidget(width = 500, height = 250) %>%
  playwidget(control,
             step = 0.01, loop = TRUE, rate = 0.5)
