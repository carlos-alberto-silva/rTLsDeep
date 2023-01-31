![](https://github.com/carlos-alberto-silva/rTLsDeep/blob/main/readme/wiki_page.png)<br/>
[![CRAN](https://www.r-pkg.org/badges/version/rTLsDeep)](https://cran.r-project.org/package=rTLsDeep)
![Github](https://img.shields.io/badge/Github-0.0.1-green.svg)
![licence](https://img.shields.io/badge/Licence-GPL--3-blue.svg) 
![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/rTLsDeep)


**rTLsDeep: An R Package for post-hurricane damage severity classification at the individual tree level using terrestrial laser scanning and deep learning.**

Authors: Carine Klauberg, Carlos Alberto Silva, Ricardo Dalagnol, Matheus Ferreira, Danilo Romeu Farias de Souza, Luiz Guilherme Almeida Nogueira, Eben Broadbent, Caio Hamamura and Jason Vogel.   

The rTLSDeep package provides options for i) rotating and deriving 2D images from TLS 3D point clouds, ii) calibrating and validating convolutional neural network (CNN) architectures and iii) predicting post-hurricane damage severity at the individual tree level  

# Getting Started


## Install R, Git and Rtools40

1. *R >= 4.0.0*: https://www.r-project.org/
1. *Rtools >= 4 (windows)*: https://cran.r-project.org/bin/windows/Rtools/
1. *Git*: https://git-scm.com/
1. *tensorflow (python)*: https://doi.org/10.5281/zenodo.3929709
1. *numpy (python)*
1. *scipy (python)*
1. *pillow (python - recommended)*

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

### Loading rTLsDeep and other required packages
```r
# get pacman
install.packages("pacman")

#load pcaman and all packages
library(pacman)
p_load(rTLsDeep,lidR,rgl,ggplot2,rgl,keras,reticulate,compiler,terra)
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
download.file("https://github.com/carlos-alberto-silva/rTLsDeep/raw/main/readme/laz_files.zip",destfile=file.path(outdir, "laz_files.zip"))

# unzip file 
unzip(file.path(outdir,"laz_files.zip"))

# Reading las file for each post-hurricane individual tree-level damage classes
tree_c1<-readLAS(file.path(outdir,"laz","Tree_c1.laz"))
tree_c2<-readLAS(file.path(outdir,"laz","Tree_c2.laz"))
tree_c3<-readLAS(file.path(outdir,"laz","Tree_c3.laz"))
tree_c4<-readLAS(file.path(outdir,"laz","Tree_c4.laz"))
tree_c5<-readLAS(file.path(outdir,"laz","Tree_c5.laz"))
tree_c6<-readLAS(file.path(outdir,"laz","Tree_c6.laz"))

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

## Post-hurricane individual tree-level damage classification using deep learning 

### Selecting deep learning model properties
```r
# Exporting 2D grids
## Creating train/test datasets for C1 and C2 only
classes = c('C1', 'C2')
targets = c('train', 'validation')

### Create folders
folders_to_create = file.path(targets, rep(classes, each=length(targets)))
sapply(folders_to_create, dir.create, recursive=T, showWarnings=FALSE)

### Calculate rotations by 15 degrees
rotations = c(seq(0, 89, 15), seq(180, 269, 15))
n_images = length(rotations) * 2 # We will use xz and yz from TLS

### Get random training samples
indices = seq_len(n_images)
val_samples = sample(indices, size=n_images * 0.25)

### Image parameters
img_width <- 256
img_height <- 256

createImage = function(raster, file_path, width, height) {
    png(paste0(file_path, '.png'), units="px", width=width, height=height)
    par(mar=c(0,0,0,0))
    terra::image(raster, col=viridis::viridis(100), axes=FALSE, ylim=c(-0.05,max_height-0.05))
    dev.off()
}

ii = 1
func = ~list(Z = max(Z)) # plot by height

## Create images rotating images
for (rotation in rotations) {
    train_or_vals = targets[(c(ii, ii+1) %in% val_samples) + 1]

    for (current_class in classes) {
        tree = tlsrotate3d(get(paste0('tree_', tolower(current_class))), theta=rotation, by="z", scale=TRUE)

        raster = getTLS2D(tree, res=resolution, by="xz", func = func, scale=TRUE)
        createImage(raster, file.path(train_or_vals[1], current_class, ii), width, height)

        raster = getTLS2D(tree, res=resolution, by="yz", func = func, scale=TRUE)
        createImage(raster, file.path(train_or_vals[2], current_class, ii + 1), width, height)
    }
    ii = ii + 2
}


# Set directory to tensorflow (python environment)
# This is required if running deep learning local computer with GPU
# Guide to install here: https://doi.org/10.5281/zenodo.3929709
tensorflow_dir = NA

# define model type
#model_type = "simple"
model_type = "vgg"
#model_type = "inception"
#model_type = "resnet"
#model_type = "densenet"
#model_type = "efficientnet"

train_image_files_path = 'train'
test_image_files_path = 'validation'

# Image and model properties
img_width <- 256
img_height <- 256
class_list_train = unique(list.files(train_image_files_path))
class_list_test = unique(list.files(test_image_files_path))
lr_rate = 0.0001
target_size <- c(img_width, img_height)
channels <- 4
batch_size = 8L
epochs = 20L

# get model
model = get_dl_model(model_type=model_type,
                     img_width=img_width,
                     img_height=img_height,
                     channels=channels,
                     lr_rate = lr_rate,
                     tensorflow_dir = tensorflow_dir,
                     class_list = class_list_train)

```
### Model calibration
```r
weights_fname = fit_dl_model(model = model,
                                 train_input_path = train_image_files_path,
                                 test_input_path = test_image_files_path,
                                 target_size = target_size,
                                 batch_size = batch_size,
                                 class_list = class_list_train,
                                 epochs = epochs,
                                 lr_rate = lr_rate)


```
### Predicting post-hurricane damage at the tree-level
```r
tree_damage<-predict_treedamage(model = model,
                            input_file_path = test_image_files_path,
                            weights = weights_fname,
                            target_size = c(256,256),
                            class_list=class_list_test,
                            batch_size = batch_size)
```
### Confusion matrix
```r
# Get damage classes for validation datasets
test_classes<-get_test_classes(file_path=test_image_files_path)

# Calculate confusion matrix
cm = confmatrix_treedamage(predict_class = tree_damage,
                           test_classes=test_classes,
                           class_list = class_list_test)
# Plot confusion matrix
gcmplot_vgg<-gcmplot(cm,
                     colors=c(low="white", high="#009194"),
                     title="densenet")
```
![](https://github.com/carlos-alberto-silva/rTLsDeep/blob/main/readme/cm.png)


# Working example using Google Colab:

<https://colab.research.google.com/drive/1YnvIca1FtHqIYwWKmp5zoPOz1Zonm7NR?usp=sharing>

# References
R Core Team. (2021). R: A Language and Environment for Statistical Computing; R Core Team: Vienna, Austria. https://www.r-project.org/

# Acknowledgements
We gratefully acknowledge funding from NIFA Award # 2020-67030-30714.

# Reporting Issues 
Please report any issue regarding the rTLsDeep package to Dr. *Carlos A. Silva* (c.silva@ufl.edu; maintainer)

# Citing rTLsDeep application
Klauberg, C., Vogel, J., Dalagnol, R., Ferreira, M., Broadbent,E.N.; Hamamura, C., Silva, C.A. Post-hurricane damage severity classification at the individual tree level using terrestrial laser scanning and deep learning. *Remote Sensing. in review*

Klauberg, C., Vogel, J., Dalagnol, R., Ferreira, M., Broadbent,E.N.; Hamamura, C., Souza, D. R. F, Silva, Nogueira, L. G. A., C.A. rTLsDeep: An R Package for post-hurricane damage severity classification at the individual tree level using terrestrial laser scanning and deep learning. Version 0.0.1, accessed on December. 30 2022, available at: https://github.com/carlos-alberto-silva/rTLsDeep


# Disclaimer
**rTLsDeep has been developed using R (R Core Team 2022), and it comes with no guarantee, expressed or implied, and the authors hold no responsibility for its use or reliability of its outputs.**

