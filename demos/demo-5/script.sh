#!/bin/bash

wget https://zhledata.blob.core.windows.net/misc/setup.sh

sh setup.sh

# install needed R libraries.

# Rscript -e 'library(devtools);devtools::install_github("rstudio/reticulate");devtools::install_github("gaborcsardi/debugme");source("https://install-github.me/MangoTheCat/processx");devtools::install_github("rstudio/keras")'

# create keras config json file.

# mkdir ~/.keras
# cat > ~/.keras/kears.json << EOF
# {
#    "floatx":"float32",
#    "image_data_format":"channels_last",
#    "epsilon":1e-01,
#    "backend":"cntk"
# }
# EOF

# echo '{"floatx":"float32","image_data_format":"channels_last","epsilon":1e-07,"backend":"cntk"}' > ~/.keras/keras.json

# export environment variables.

# cat > .Rprofile << EOF
# Sys.setenv(KERAS_BACKEND="cntk")
# Sys.setenv(KERAS_PYTHON="/anaconda/envs/py35/bin/python")
# EOF

# echo 'Sys.setenv(KERAS_BACKEND="cntk")' > .Rprofile
# echo 'Sys.setenv(KERAS_PYTHON="/anaconda/envs/py35/bin/python3.5")' >> .Rprofile

# turn on Rstudio server.

rstudio-server start
