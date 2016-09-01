# This is an R script to test the makeCluster function.
library(parallel)

# IP address of a DSVM is 52.175.19.32.

cl <- makePSOCKcluster(names = "52.175.19.32",
                       # master = "localhost",
                       user = "zhle",
                       homogeneous = TRUE,
                       rscript = "/usr/bin/Rscript",
                       methods = FALSE,
                       manual = TRUE,
                       outfile = "out.log")