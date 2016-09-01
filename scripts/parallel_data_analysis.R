# TITLE: Parallel Computing on DSVM server nodes
# DESCRIPTION: This script show how to perform parallel computation on distributed DSVMs. The demo codes
#              are from the book "parallel R" written by Steve Weston.
# AUTHOR: Zhang Le
# DATE OF CREATION : 29/08/2016

# libraries used.
library(MASS)
library(parallel)
library(snow)

# Use the available DSVM nodes.
master <- "52.175.28.49"
nodes <- c(node1 = "52.175.24.148",
           node2 = "23.99.109.230",
           node3 = "23.99.99.72")

# create a cluster by using the three nodes.
cl <- makePSOCKcluster(nodes, user = "zhle", master = master)

summary(cl)

################### lapply on the distributed nodes.
# single node version
time1Sing <- snow.time(lapply(1:1e6, function(exponential) 2^exponential))
# cluster nodes version
time1Para <- snow.time(parLapply(cl, 1:1e6, function(exponential) 2^exponential))
table(Single = time1Sing, Parallel = time1Para)

################### distributed k-means.
# single node version
results <- lapply(rep(25, 4), function(nstart) kmeans(Boston, 4, nstart=nstart)) 
i <- sapply(results, function(result) result$tot.withinss) 
result <- results[[which.min(i)]] 

# cluster nodes version
ignore <- clusterEvalQ(cl, {library(MASS); NULL}) 
results <- clusterApply(cl, rep(25, 4), function(nstart) 
kmeans(Boston, 4, nstart=nstart)) 
i <- sapply(results, function(result) result$tot.withinss) 
result <- results[[which.min(i)]]

