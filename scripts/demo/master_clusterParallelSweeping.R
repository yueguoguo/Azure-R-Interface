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

source("./rInterfaceObject.R")

# ----------------------------------------------------------------------
# Get the info of available Azure resources.
# ----------------------------------------------------------------------
RG  <- "<resource-group>"
TID <- "<tenant-id>"
CID <- "<client-id>"
KEY <- "<app-key>"

sc <- CreateAzureContext()
SetAzureContext(sc,
                TID = TID,
                CID = CID,
                KEY = KEY)
AzureAuthenticate(sc)
DumpAzureContext(sc)

rg_list <- AzureListRG(sc) %T>%
  print()
location <- as.character(rg_list %>% filter(Name == RG) %>% select(Location)) %T>%
  print()
vm_list <- AzureListVM(AzureActiveContext = sc, ResourceGroup = RG) %T>%
  print()
vm_names <- as.character(vm_list$Name)

# check the status of VMs.
for (vm in vm_names) {
  vm.status <- AzureVMStatus(AzureActiveContext = sc, ResourceGroup = RG, VMName = vm)
  print(str_c(vm, vm.status, sep = ", "))
}

# switch on the VMs in the resource group.
for (vm in vm_names) {
  # skip the error in the AzureStartVM function.
  outputs <- try(AzureStartVM(AzureActiveContext = sc, ResourceGroup = RG, VMName = vm))
  if (inherits(outputs, "try_error")) continue
}

vm.dns.list <- paste(vm_names, ".", location, ".cloudapp.azure.com", sep = "")

# ----------------------------------------------------------------------
# Set up the interface and fire the work.
# ----------------------------------------------------------------------
# Select one to be the master node while some others to be the slaves.
index <- sample(x = 1:length(vm.dns.list), 1)
MACHINES        <- vm_names
MACHINES_URL    <- vm.dns.list
MASTER_URL      <- vm.dns.list[index]
SLAVES_URL      <- vm.dns.list[-index]

# Create a new interface.
interface <- new("rInterface")

# Set the interface.
interface <- riSet(object = interface,
                    remote = MASTER_URL,
                    user = "<user-name>"
)

# Configure the interface.
interface <- riConfig(object = interface, 
                      machine.list = MACHINES, 
                      data = "<reference-to-data>",
                      dns.list = MACHINES_URL, 
                      machine.user = "<user-name>",
                      master = MASTER_URL, 
                      slaves = SLAVES_URL, 
                      context = "clusterParallel")

# Create a new worker script.
script_path <- "./worker_scripts"
script_title <- "worker_clusterParallelSweep.R"
if (!file.exists(file.path(script_path, script_title))) {
  riNewScript(path = script_path,
               title = script_title)
}

# Set the script to the interface object, and update the new worker script with config information.
interface@script <- file.path(script_path, script_title)
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
for (vm in vm_names) {
  # skip the error in the AzureStartVM function.
  outputs <- try(AzureStopVM(AzureActiveContext = sc, ResourceGroup = RG, VMName = vm))
  if (inherits(outputs, "try_error")) continue
}
