## docker build --progress=plain -t rtlsdeep .
## docker create -it --name=rbasetest r_base
## docker start rbasetest
## docker exec -it rbasetest /bin/bash

FROM r-base

RUN apt update -yy
RUN apt install git -y

RUN ["git","clone","--depth=1","https://github.com/carlos-alberto-silva/rTLsDeep"]
WORKDIR rTLsDeep

RUN ["touch", "/root/.Rprofile"]
RUN "echo" "options(repos=list(CRAN='https://brieger.esalq.usp.br/CRAN/'))" > /root/.Rprofile


RUN apt install --no-install-recommends r-cran-curl r-cran-data.table r-cran-caret r-cran-ggplot2 r-cran-matrixstats r-cran-reticulate r-cran-rgl r-cran-sf r-cran-terra r-cran-viridis -y

RUN ["Rscript", "-e", "install.packages('remotes')"]

RUN apt install libudunits2-dev libssl-dev libgdal-dev -y

RUN apt install --no-install-recommends r-cran-ps r-cran-backports r-cran-rstudioapi r-cran-whisker r-cran-processx r-cran-lwgeom r-cran-abind r-cran-bh r-cran-sp r-cran-zeallot r-cran-rcpparmadillo r-cran-stars r-cran-raster -y

RUN ["Rscript", "-e", "remotes::install_deps(dependencies=TRUE, upgrade='never')"]
RUN ["Rscript", "-e", "remotes::install_local('.', dependencies=FALSE)"]

RUN git pull

RUN apt install python3.11-venv -y
ENV _R_CHECK_CRAN_INCOMING_ false

RUN R CMD build .
RUN R CMD check rTLsDeep_$(sed -n 's/Version: \(.*\)/\1/p' DESCRIPTION).tar.gz --as-cran --no-manual

CMD R