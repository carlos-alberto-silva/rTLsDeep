![](https://github.com/carlos-alberto-silva/rTLsDeep/blob/main/readme/wiki_page.png)<br/>
[![CRAN](https://www.r-pkg.org/badges/version/rTLsDeep)](https://cran.r-project.org/package=rTLsDeep)
![Github](https://img.shields.io/badge/Github-0.0.1-green.svg)
![licence](https://img.shields.io/badge/Licence-GPL--3-blue.svg) 
![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/rTLsDeep)


**rTLsDeep: An R Package for post-hurricane individual tree-level damage classification from terrestrial laser scanning and deep learning.**

Authors: Carine Klauberg, Carlos Alberto Silva, Matheus Ferreira, Ricardo Dalagnol, Eben Broadbent and Jason Vogel.   

The rTLSDeep package provides options for i) rotating and deriving 2D images from TLS 3D point clouds, ii) calibrating and validating deep learning classification models and iii) predicting post-hurricane individual tree-level damages  

# Getting Started


## Install R, Git and Rtools40

i) *R (>= 4.0.0)*: https://www.r-project.org/

ii) *Git*: https://git-scm.com/

iii) *tensorflow (python environment)*: https://doi.org/10.5281/zenodo.3929709

## rTLsDeep installation
```r
# The CRAN version:
install.packages("rTLsDeep")

# The development version:
#install.packages("remotes")
library(remotes)
install_github("https://github.com/carlos-alberto-silva/rTLsDeep", dependencies = TRUE)
```    

## Getting Started

### Loading rTLsDeep
```r
# get packman
install.packages("packman")

library(pacman)
p_load(lidR,rTLsDeep,rgl,ggplot2,rgl,keras,reticulate,compiler)
```

## TLS data processing

<img align="right" src="https://github.com/carlos-alberto-silva/rTLsDeep/blob/main/readme/fig1_3d.PNG">

### Loading and visualizing TLS dataset 
```r
# Path to las file
lasfile <- system.file("extdata", "tree_c1.laz", package="rTLsDeep")

# Reading las file
las<-readLAS(lasfile)

# plotting las file in 3D
plot(las, bg="white")
rgl::axes3d(c("x+", "y-", "z-"), col="black")
rgl::grid3d(side=c('x+', 'y-', 'z'), col="gray")
```

<img align="left" src="https://github.com/carlos-alberto-silva/rTLsDeep/blob/main/readme/spin3d.gif">

### Rotating TLS-derived 3d point cloud 
```r
# Rotating around the x-axis
las<-tlsrotate3d(las,theta=120, by="x", scale=TRUE)

# Rotating around the y-axis
las<-tlsrotate3d(las,theta=120, by="y", scale=TRUE)

# Rotating around the z-axis
las<-tlsrotate3d(las,theta=120, by="z", scale=TRUE)
```


![](https://github.com/carlos-alberto-silva/rTLsDeep/blob/main/readme/fig2_rotation.png)

### Capturing 2D grid snapshot
```r
# Set output dir for downloading the example dataset files
outdir=getwd()

# downloading zip file
download.file("https://github.com/carlos-alberto-silva/rTLsDeep/tree/main/readme/laz_files.zip",destfile=file.path(outdir, "laz_files.zip"))

# unzip file 
unzip(file.path(outdir,"laz_files.zip"))

# Reading las file for each post-hurricane individual tree-level damage classes
tree_c1<-readLAS(paste0(outdir,"//Tree_c1.laz"))
tree_c2<-readLAS(paste0(outdir,"//Tree_c2.laz"))
tree_c3<-readLAS(paste0(outdir,"//Tree_c3.laz"))
tree_c4<-readLAS(paste0(outdir,"//Tree_c4.laz"))
tree_c5<-readLAS(paste0(outdir,"//Tree_c5.laz"))
tree_c6<-readLAS(paste0(outdir,"//Tree_c6.laz"))

# Defining the func parameter
func = ~list(Z = max(Z)) # plot by height

# computing 2D grid snapshot
gtree_c1<-getTLS2D(tree_c1, res=0.05, by="xz", func = func, scale=TRUE)
gtree_c2<-getTLS2D(tree_c2, res=0.05, by="xz", func = func, scale=TRUE)
gtree_c3<-getTLS2D(tree_c3, res=0.05, by="xz", func = func, scale=TRUE)
gtree_c4<-getTLS2D(tree_c4, res=0.05, by="xz", func = func, scale=TRUE)
gtree_c5<-getTLS2D(tree_c5, res=0.05, by="xz", func = func, scale=TRUE)
gtree_c6<-getTLS2D(tree_c6, res=0.05, by="xz", func = func, scale=TRUE)

# Visualizing 2D grid snapshot
par(mfrow=c(2,3))
plot(gtree_c1, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,30), main="C1",cex=2)
plot(gtree_c2, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,30), main="C2",cex=2)
plot(gtree_c3, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,30), main="C3",cex=2)
plot(gtree_c4, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,30), main="C4",cex=2)
plot(gtree_c5, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,30), main="C5",cex=2)
plot(gtree_c6, col=viridis::viridis(100),axes=FALSE, xlab="",ylab="", ylim=c(0,30), main="C6",cex=2)
```
![](https://github.com/carlos-alberto-silva/rTLsDeep/blob/main/readme/fig3_trees.png)

## Post-hurricane individual tree-level damanage using deep learning 

### Selecting deep learning model properties
```r
# Set directory to tensorflow (python environment)
# This is required if running deep learning local computer with GPU
# Guide to install here: https://doi.org/10.5281/zenodo.3929709
tensorflow_dir = 'C:\\ProgramData\\Miniconda3\\envs\\r-tensorflow'

# define model type
#model_type = "simple"
model_type = "vgg"
#model_type = "inception"
#model_type = "resnet"
#model_type = "densenet"
#model_type = "efficientnet"

# Image and model properties
img_width <- 256
img_height <- 256
class_list = as.character(1:6)
lr_rate = 0.0001
target_size <- c(img_width, img_height)
channels <- 4
batch_size = 8L
epochs = 20L


# path to image folders - black
train_image_files_path <- getwd() # update the path for training datasets
valid_image_files_path <- getwd() # update the path for testing datasets

# get model
model = get_dl_model(model_type=model_type,
                     img_width=img_width,
                     img_height=img_height,
                     lr_rate = lr_rate,
                     tensorflow_dir = tensorflow_dir,
                     class_list = class_list)

```
### Model calibration
```r
weights_fname = fit_dl_model(model = model,
                                 train_input_path = train_image_files_path,
                                 test_input_path = valid_image_files_path,
                                 target_size = target_size,
                                 batch_size = batch_size,
                                 class_list = as.character(1:6),
                                 epochs = epochs,
                                 lr_rate = lr_rate)


```
### Predicting post-hurricane damage at the tree-level
```r
tree_damage<-predict_treedamage(model = model,
                            input_file_path = getwd(),
                            weights = weights,
                            target_size = c(256,256),
                            class_list=class_list,
                            batch_size = batch_size)

```
### Confusion matrix
```r
# Calculate confusion matrix
cm = confmatrix_treedamage(pred_df = tree_damage, class_list = class_list)

# Plot confusion matrix
gcmplot_vgg<-gcmplot(cm,
                     colors=c(low="white", high="#009194"),
                     title="densenet")
```
![](https://github.com/carlos-alberto-silva/rTLsDeep/blob/main/readme/cm.png)

# References
R Core Team. (2021). R: A Language and Environment for Statistical Computing; R Core Team: Vienna, Austria. https://www.r-project.org/

# Acknowledgements
We gratefully acknowledge funding from NIFA Award # 2020-67030-30714.

# Reporting Issues 
Please report any issue regarding the rTLsDeep package to Dr. *Carlos A. Silva* (c.silva@ufl.edu; maintainer)

# Citing treetop application
Klauberg, C. 2021; Silva, C.A.; Ferreira, M.; Dalagnol, R.; Broadbent,E.N.; Vogel, J. G. rTLsDeep: An R Package for individual tree level post-hurricane damage classification from terrestrial laser scanning and deep learning. *Methods in Ecology and Evolution (In prep).*

Klauberg, C. 2021; Silva, C.A.; Ferreira, M.; Dalagnol, R.; Broadbent,E.N.; Vogel, J. G. rTLsDeep: An R Package for individual tree level post-hurricane damage classification from terrestrial laser scanning and deep learning. Version 0.0.1, accessed on March. 13 2021, available at: https://CRAN.R-project.org/package=rTLsDeep

# Disclaimer
**rTLsDeep has been developed using in R (R Core Team 2022), and it comes with no guarantee, expressed or implied, and the authors hold no responsibility for its use or reliability of its outputs.**

