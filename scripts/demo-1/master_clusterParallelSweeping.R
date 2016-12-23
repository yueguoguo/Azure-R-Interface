# ----------------------------------------------------------------------
# Master script for cluster parallel experiments to sweep parameters.
# ----------------------------------------------------------------------
# AUTHORS:            Zhang Le.
# CONTRIBUTORS:       Zhang Le.
# DATE OF CREATION:   20161028
# DEPARTMENT:         IMML & ADS
# COMPANY:            Microsoft
# ----------------------------------------------------------------------

# libraries used.
library(AzureSMR)
library(magrittr)
library(dplyr)

# ----------------------------------------------------------------------
# Get the info of available Azure resources.
# ----------------------------------------------------------------------

LOCAL_SETTINGS <- paste0("settings_", Sys.info()['user'], ".R")
if (file.exists(LOCAL_SETTINGS))
{
  source(LOCAL_SETTINGS)
} else {
  source("settings.R")
}

# Authenticate the Azure account.

sc <- createAzureContext(tenantID=TID, clientID=CID, authKey=KEY) %T>% print()

rg_list <- azureListRG(sc) %T>%
  print()
location <- as.character(rg_list %>% filter(name == RG) %>% select(location)) %T>%
  print()
vm_list <- azureListVM(azureActiveContext = sc, resourceGroup = RG) %T>%
  print()
vm_names <- as.character(vm_list$name)

# check the status of VMs.
for (vm in vm_names) {
  vm_status <- azureVMStatus(azureActiveContext = sc, resourceGroup = RG, vmName = vm)
  print(paste0(vm, vm_status, sep = ", "))
}

# switch on the VMs in the resource group.
for (vm in vm_names) {
  azureStartVM(azureActiveContext = sc, resourceGroup = RG, vmName = vm)
}

vm_dns_list <- paste(vm_names, ".", location, ".cloudapp.azure.com", sep = "")

# ----------------------------------------------------------------------
# Set up the interface and fire the work.
# ----------------------------------------------------------------------
# Select one to be the master node while some others to be the slaves.
index <- sample(x = 1:length(vm_dns_list), 1)
MACHINES        <- vm_names
MACHINES_URL    <- vm_dns_list
MASTER_URL      <- vm_dns_list[index]
SLAVES_URL      <- vm_dns_list[-index]

# Create a new interface.
source("rInterfaceObject.R")

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
script_path <- "."
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
  azureStopVM(azureActiveContext = sc, resourceGroup = RG, vmName = vm)
}
