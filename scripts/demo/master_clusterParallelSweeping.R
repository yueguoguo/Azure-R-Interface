# ----------------------------------------------------------------------
# Master script for cluster parallel experiments to sweep parameters.
# ----------------------------------------------------------------------
# AUTHORS:            Zhang Le.
# CONTRIBUTORS:       Zhang Le.
# DATE OF CREATION:   10-28-2016
# DEPARTMENT:         IMML & ADS
# COMPANY:            Microsoft
# ----------------------------------------------------------------------

# libraries used.
library(AzureSM)
library(httr)
library(plyr)
library(jsonlite)
library(XML)
library(magrittr)
library(dplyr)
library(stringr)

# source("./scripts/rInterface/rInterfaceObject.R")
source("./scripts/rInterface/rInterfaceObject_2016oct26.R")

# ----------------------------------------------------------------------
# Get the info of available Azure resources.
# ----------------------------------------------------------------------
RG <- "dsvm"
TID <- "72f988bf-86f1-41af-91ab-2d7cd011db47"
CID <- "5070f69d-5299-43c4-920c-a4de19f6ea6c"
KEY <- "gISaoqGu4zNPnrNkvPIoYTmaAVbs4Izt4VCFwIs48yg="

sc <- CreateAzureContext()
SetAzureContext(sc,
                TID = TID,
                CID = CID,
                KEY = KEY)
AzureAuthenticate(sc)
DumpAzureContext(sc)

rg.list <- AzureListRG(sc) %T>%
  print()
location <- as.character(rg.list %>% filter(Name == RG) %>% select(Location)) %T>%
  print()
vm.list <- AzureListVM(AzureActiveContext = sc, ResourceGroup = RG) %T>%
  print()
vm.names <- as.character(vm.list$Name)

# check the status of VMs.
for (vm in vm.names) {
  vm.status <- AzureVMStatus(AzureActiveContext = sc, ResourceGroup = RG, VMName = vm)
  print(str_c(vm, vm.status, sep = ", "))
}

# switch on the VMs in the resource group.
for (vm in vm.names) {
  # skip the error in the AzureStartVM function.
  outputs <- try(AzureStartVM(AzureActiveContext = sc, ResourceGroup = RG, VMName = vm))
  if (inherits(outputs, "try_error")) continue
}

vm.dns.list <- paste(vm.names, ".", location, ".cloudapp.azure.com", sep = "")

# ----------------------------------------------------------------------
# Set up the interface and fire the work.
# ----------------------------------------------------------------------
# Select one to be the master node while some others to be the slaves.
index <- sample(x = 1:length(vm.dns.list), 1)
MACHINES        <- vm.names
MACHINES_URL    <- vm.dns.list
MASTER_URL      <- vm.dns.list[index]
SLAVES_URL      <- vm.dns.list[-index]

# Create a new interface.
interface <- new("rInterface")

# Set the interface.
interface <- riSet(object = interface,
                    remote = MASTER_URL,
                    user = "zl"
)

# Configure the interface.
interface <- riConfig(object = interface, 
                      machine.list = MACHINES, 
                      data = "https://msvm001sa.blob.core.windows.net/data/train_FD001.csv",
                      dns.list = MACHINES_URL, 
                      machine.user = "zl",
                      master = MASTER_URL, 
                      slaves = SLAVES_URL, 
                      context = "clusterParallel")

# Create a new worker script.
script.path <- "./scripts/worker_scripts"
script.title <- "worker_clusterParallelSweep.R"
if (!file.exists(file.path(script.path, script.title))) {
  riNewScript(path = script.path,
               title = script.title)
}

# Set the script to the interface object, and update the new worker script with config information.
interface@script <- file.path(script.path, script.title)
riScript(interface)
file.edit(interface@script)

# Dump info about the interface.
riDump(interface)

# Remote execute the script with the specified config.
result <- riExecute(object = interface,
                     roptions = "--verbose",
                     verbose = TRUE)

# ----------------------------------------------------------------------
# Clean up and stop the VMs.
# ----------------------------------------------------------------------
for (vm in vm.names) {
  # skip the error in the AzureStartVM function.
  outputs <- try(AzureStopVM(AzureActiveContext = sc, ResourceGroup = RG, VMName = vm))
  if (inherits(outputs, "try_error")) continue
}
