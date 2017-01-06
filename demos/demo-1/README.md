# Introduction 
This demonstration presents how to form a high performance cluster on top of Azure Linux Data Science Virtual Machines, and submit scalable analytical jobs to the cluster with the help of an **R Interface**. A `AzureSMR` package is used to harness Azure instances such as virtual machines all within R session - no bother from GUI interaction and PowerShell scripting. A use case on predictive maintenance is illustrated. 

## Prerequisites
* R >= 3.3
* `AzureSMR` package.
* Azure account subscription.
* Application in Azure Active Directory with allowed access to the resource group.
* SSH toolkit.

## Description of the scripts in folder.
* `settings.R`
Global settings - ID, key, and usernames used in the other scripts.
* `utils/rInterfaceObject.R`
S4 class and method of rInterface which specify computing nodes and context.
* `master.R`
Master script that specifies the experiment environment such as header
node, compute context, etc., for the analytical jobs. 
* `worker.R`
The worker script contains the actual analytics. A predictive
maintenance use case is demonstrated here.

## Instructions on demo
1. Write the R script that to remotely executed on VM cluster. 
2. Customize master.R script with specified VM cluster, remote R script, and compute context set up, and run it.

## Use case - predictive maintenance
Use case in the demo is a common problem in predictive maintenance scenario, which is to diagnose *health status of a machine given the historical observations on the sensors incorporated in the machine*.

### Introduction
Maintaining working reliability of electrical and/or mechanical system is vital to assure quality of service and thus restrain unexpected cost. For instance, in aerospace industry, malfunction or parameter deviation of a flight component, may cause service disruption that induces huge loss. 

Predictive maintenance is proven to be efficient to forecast failure events of system component, so as to save the cost of regular maintenance visit. The conventional paradigm of predictive maintenance may refer to several data analytical problems, predicting a failure event of a machine within the next a few working cycles, predicting the Remaining Useful Life (RUL) of a machine, and so on. [Website of Microsoft Cortana Intelligence Suite](https://gallery.cortanaintelligence.com/Collection/Predictive-Maintenance-Template-3) covers a detailed introduction for predictive maintenance. 

### Scalable analytics with Azure R interface
To develop a model with best prediction power, data scientists need to work tightly with domain experts, and experiment on the observation samples with different sets of hyperparameters until one that yields the optimal results is found. Apparently scalable computation resources are required for performing such exploratory analytics, and it would be even better the analytics can be fired up on computation resources of easy control. Azure R Interface fits perfectly in solving this type of problem - it provides R based methods to invoke and manage Azure cloud instances with minimal interactions on GUI, and execute scalable analytical jobs on the deployed instances with customized computation contexts which are available in Microsoft R Server. 

In predictive maintenance scenarios, it is often a necessity to diagnose whether an equipment is working under a healthy status or not, and then proceed with further finer-grained failure predictions. False alarms produced by a failure prediction model that takes data in the most recent working cycles as input can be therefore avoided. Health status recognition considers a even longer period of cycling history of the machine. Based on the observations in training set, the model tells whether the machine is in a "healthy" status, or a "close-to-fail" status. Based on the diagnose result of health status, a failure prediction model with finer granularity of predicting interval can be then executed. 

To optimize the model performance, it is pivotal to select hyper-parameters used in both predictive models and feature engineering process. Normally there are built-in methods in model implementations for parameter fine-tuning. However, for the parameters in feature engineering which are rather specific to problems, iterative search for combination of parameters that yield the best results should be performed. For example, in an illustrative case, the health status recognition scenario, **length of time series data** and **prediction time window** are the two hyperparameters considerd in feature engineering. 

In the demonstrated analysis (as scripted in `worker_clusterParallelSweep.R`), [NASA turbo fan engine degradation data sets](https://ti.arc.nasa.gov/tech/dash/pcoe/prognostic-data-repository/) are used to validate the hypothesis of health status diagnose. The sensor observations in the whole life time of a fan engine are partitioned into two groups, i.e., "high risk" group and "low risk" group. The original sensor values are aggregated as features by using the method as aforementioned. The features derived from sensor measures for each time point (in the data set, time unit is machine working cycle) are labelled according to the risk group that the sampled data belong to. The problem is therefore becomes a classification problem - given the sensor measure values of a turbo fan for long enough cycles, by analyzing the features derived from the lagged sensor measures, the model is to recognize which risk group the turbo fan belongs to. In the experiment, a boosted tree algorithm available in `RevoScaleR` package is used. To boost the execution performance, the demo constructs a cluster of Azure DSVMs to run the analytics with `rxExec` method. Note this is an embarassing parallelism which is essentially different from that on Hadoop/Spark. It basically leverages on the multiple cores (if it is a single node) or multiple nodes (if there are more than one nodes) to accelerate execution of analytical jobs. The underneath mechanism of the parallelism is based on socket communication or MPI, and it is well implemented in `snow` and `doParallel` packages. It is worth mentioning that it is feasible to interact with Hadoop/Spark sessions by using the methods provided by `AzureSMR` package, but this is yet to be implemented in the demo scripts. 
