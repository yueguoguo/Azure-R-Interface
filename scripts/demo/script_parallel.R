# -------------------------------------------------------------------------------------------
# ORIGINAL CODE STARTS HERE
# -------------------------------------------------------------------------------------------
# single node version
time1Sing <- system.time(lapply(1:1e6, function(exponential) 2^exponential))

# cluster nodes version
time1Para <- system.time(parLapply(cl, 1:1e6, function(exponential) 2^exponential))
table(Single = time1Sing, Parallel = time1Para)
