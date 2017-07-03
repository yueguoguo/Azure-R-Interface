#!/bin/bash

Rscript -e 'library(devtools);devtools::install_github("rstudio/reticulate");devtools::install_github("gaborcsardi/debugme");source("https://install-github.me/MangoTheCat/processx");devtools::install_github("rstudio/keras")'

mkdir ~/.keras
echo '{"floatx":"float32","image_data_format":"channels_last","epsilon":1e-07,"backend":"cntk"}' > ~/.keras/keras.json

echo 'Sys.setenv(KERAS_BACKEND="cntk")' > .Rprofile
echo 'Sys.setenv(KERAS_PYTHON="/anaconda/envs/py35/bin/python3.5")' >> .Rprofile

rstudio-server start
