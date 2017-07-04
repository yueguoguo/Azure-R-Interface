# install packages.

library(devtools)

devtools::install_github("rstudio/reticulate")
devtools::install_github("gaborcsardi/debugme")
source("https://install-github.me/MangoTheCat/processx")
devtools::install_github("rstudio/keras")

# create the keras.json config file at ~/.keras.

home_path <- file.path("~")
keras_path <- file.path(home_path, ".keras")
keras_file <- file.path(keras_path, "keras.json")
profile_file <- file.path(home_path, ".Rprofile")

dir.create(keras_path)
file.create(keras_file, overwrite=TRUE)
keras_json <- '{"floatx":"float32","image_data_format":"channels_last","epsilon":1e-07,"backend":"cntk"}'
writeLines(keras_json, con=keras_file)

# create a .Rprofile at ~

file.create(profile_file, overwrite=TRUE)
r_profile <- 'Sys.setenv(KERAS_BACKEND="cntk"); Sys.setenv(KERAS_PYTHON="/anaconda/envs/py35/bin/python3.5")'
writeLines(r_profile, con=profile_file)
