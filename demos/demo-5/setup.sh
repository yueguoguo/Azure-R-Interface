#!/bin/bash

# install "reticulate"/"debugme"/"processx"/"keras". 

sudo Rscript -e 'library(devtools);devtools::install_github("rstudio/reticulate");devtools::install_github("gaborcsardi/debugme");source("https://install-github.me/MangoTheCat/processx");devtools::install_github("rstudio/keras")'

# downgrade CNTK. CNTK2.0RC1 is pre-installed but it does not have
# attribute set_global_option for initializing properly.

sudo /anaconda/envs/py35/bin/pip install
https://cntk.ai/PythonWheel/GPU/cntk-2.0-cp35-cp35m-linux_x86_64.whl

# upgrade pip and keras. By default keras R package does not install the
# latest version so there is no CNTK backend supported.

sudo /anaconda/envs/py35/bin/pip install --upgrade pip
sudo /anaconda/envs/py35/bin/pip install --upgrade keras 

# run keras once so that ~/.keras/keras.json is generated.

python -c 'import keras'

# Default backend is TensorFlow. Change it to CNTK.

find ~/.keras/keras.json -type f -exec sed -i 's/tensorflow/cntk/g' {} \;

