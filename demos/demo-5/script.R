# install packages.

library(devtools)
library(jsonlite)

devtools::install_github("rstudio/reticulate")
devtools::install_github("gaborcsardi/debugme")
source("https://install-github.me/MangoTheCat/processx")
devtools::install_github("rstudio/keras")

# create the keras.json config file at ~/.keras.

dir.create("~/.keras")
file.create("~/.keras/keras.json")
df <- data.frame(floatx="float32",
                 image_data_format="channels_last",
                 epsilon=1e-7,
                 backend="cntk")
df_json <- toJOSN(df)
writeLines(df_json, con="~/.keras/keras.json")

# create a .Rprofile at ~

file.create("~/.Rprofile")
profile <- 'Sys.setenv(KERAS_BACKEND="cntk"); Sys.setenv(KERAS_PYTHON="/anaconda/envs/py35/bin/python3.5")'
writeLines(profile, con="~/.Rprofile")
