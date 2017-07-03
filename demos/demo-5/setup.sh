#!/bin/bash

# install "reticulate"/"debugme"/"processx"/"keras". 

Rscript -e 'library(devtools);devtools::install_github("rstudio/reticulate");devtools::install_github("gaborcsardi/debugme");source("https://install-github.me/MangoTheCat/processx");devtools::install_github("rstudio/keras")'

# downgrade CNTK. CNTK2.0RC1 is pre-installed but it does not have
# attribute set_global_option for initializing properly.

# sudo /anaconda/envs/py35/bin/pip install https://cntk.ai/PythonWheel/GPU/cntk-2.0-cp35-cp35m-linux_x86_64.whl

# upgrade keras. By default keras R package does not install the
# latest version so there is no CNTK backend supported.

# sudo /anaconda/envs/py35/bin/pip install --upgrade keras 

# make a keras config file

# echo '{"floatx":"float32","image_data_format":"channels_last","epsilon":1e-07,"backend":"cntk"}' > ~/.keras/keras.json

Rscript -e 'library(keras)'

sed -i 's/tensorflow/cntk/g' ~/.keras/keras.json

# add environment variables.
# export KERAS_BACKEND="cntk"
# export KERAS_PYTHON="/anaconda/envs/py35/bin/python3.5"

# Switch on RStudio Server

rstudio-server start
