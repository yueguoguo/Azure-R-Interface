#!/bin/bash

# install R libraries.

Rscript -e 'library(devtools);devtools::install_github("rstudio/reticulate");devtools::install_github("gaborcsardi/debugme");source("https://install-github.me/MangoTheCat/processx");devtools::install_github("rstudio/keras")'

# create keras config json file.

mkdir /etc/skel/.keras
echo '{"floatx":"float32","image_data_format":"channels_last","epsilon":1e-07,"backend":"cntk"}' > /etc/skel/.keras/keras.json

# export environment variables.

echo 'Sys.setenv(KERAS_BACKEND="cntk")' > /etc/skel/.Rprofile
echo 'Sys.setenv(KERAS_PYTHON="/anaconda/envs/py35/bin/python3.5")' >> /etc/skel/.Rprofile

# cp /etc/skel to home directory of all users.

USR=$(ls /home | grep user)

for u in ${USR}; do
  DBASE="/home/$u/"
  
  cp -rf /etc/skel/.keras ${DBASE}/
  cat /etc/skel/.Rprofile >> ${DBASE}/.Rprofile
  
  chown -R $u.$u ${DBASE}/.keras
  chown -R $u.$u ${DBASE}/.Rprofile
done 

# turn on Rstudio server.

rstudio-server start
