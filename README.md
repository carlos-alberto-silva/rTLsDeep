![](https://github.com/carlos-alberto-silva/rTLsDeep/blob/main/readme/wiki_page.png)<br/>

[![CRAN](https://www.r-pkg.org/badges/version/treetop)](https://cran.r-project.org/package=rTLsDeep)
![Github](https://img.shields.io/badge/Github-0.0.1-green.svg)
![licence](https://img.shields.io/badge/Licence-GPL--3-blue.svg) 
![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/rTLsDeep)


**rTLsDeep: An R Package for individual tree-level post-hurricane damage classification from terrestrial laser scanning and deep learning.**

Authors: Carine Klauberg, Carlos Alberto Silva, Matheus Ferreira, Ricardo Dalagnol, Eben Broadbent and Jason Vogel.   

The rTLSDeep package provides options for i) deriving 2D images from TLS point cloud, ii) calibrating and validating deep learning classification models and iii) predicting post-hurricane damage at the tree-level 

# Getting Started


## Install R, Git and Rtools40

i) *R (>= 4.0.0)*: https://www.r-project.org/

ii) *Git*: https://git-scm.com/

iii) *Rtools40*: https://cran.r-project.org/bin/windows/Rtools/


## Treetop installation
```r
# The CRAN version:
install.packages("rTLsDeep")

# The development version:
#install.packages("remotes")
library(remotes)
install_github("https://github.com/carlos-alberto-silva/rTLsDeep", dependencies = TRUE)

```    

## Loading and launching treetop application
```r
library(rTLsDeep)

```
<img src="https://github.com/carlos-alberto-silva/weblidar-treetop/blob/master/readme/rTLsDeep.gif">

# References

R Core Team. (2021). R: A Language and Environment for Statistical Computing; R Core Team: Vienna, Austria. https://www.r-project.org/


# Acknowledgements
We gratefully acknowledge funding from the XXX and XXX, grant XXX  and XXX. 

# Reporting Issues 
Please report any issue regarding the rTLsDeep package to Dr. *Carine Klauberg* (carine.klaubergs@ufl.edu) and Dr. *Carlos A. Silva* (c.silva@ufl.edu)

# Citing treetop application
Klauberg, C. 2021; Silva, C.A.; Ferreira, M.; Dalagnol, R.; Broadbent,E.N.; Vogel, J. G. rTLsDeep: An R Package for individual tree level post-hurricane damage classification from terrestrial laser scanning and deep learning. *Methods in Ecology and Evolution (In prep).*

Klauberg, C. 2021; Silva, C.A.; Ferreira, M.; Dalagnol, R.; Broadbent,E.N.; Vogel, J. G. rTLsDeep: An R Package for individual tree level post-hurricane damage classification from terrestrial laser scanning and deep learning. Version 0.0.1, accessed on March. 13 2021, available at: https://CRAN.R-project.org/package=rTLsDeep

# Disclaimer
**rTLsDeep has been developed using in R (R Core Team 2021), and it comes with no guarantee, expressed or implied, and the authors hold no responsibility for its use or reliability of its outputs.**

