# -------------------------------------------------------------------------
# Churn prediction with sentiment analysis
#
# Master script 
#
# Do environment setup and computing context configuration in this script.
# Put the actual analytics in the worker script will be executed remotely
# on a more powerful node.
#
# Author:   Le Zhang
# Date:     20161227
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Set up
# -------------------------------------------------------------------------

# libraries used

library(AzureSMR)

# global variables

# DATA1 - HR demographic data.
# DATA2 - both demographic and sentiment data - text processed by bag-of-words model.
# DATA3 - both demographic and sentiment data - text processed by Microsoft Cognitive Services.

DATA1 <- "https://projectsdisks415.blob.core.windows.net/data/dataset1.csv"
DATA2 <- "https://projectsdisks425.blob.core.windows.net/data/dataset2.csv"
DATA3 <- "https://projectsdisks435.blob.core.windows.net/data/dataset3.csv"

# -------------------------------------------------------------------------
# DSVM instantialization
# -------------------------------------------------------------------------

LOCAL_SETTINGS <- paste0("settings_", Sys.info()['user'], ".R")
if (file.exists(LOCAL_SETTINGS))
{
  source(LOCAL_SETTINGS)
} else {
  source("settings.R")
}

# authenticate Azure account.

sc <- AzureSMR::createAzureContext(tenantID=TID, clientID=CID, authKey=KEY) 

vm_list <- AzureSMR::azureListVM(azureActiveContext = sc, resourceGroup = RG) 
vm_name <- sample(as.character(vm_list$name), 1)
vm_url <- paste(vm_name, ".", LOC, ".cloudapp.azure.com", sep = "")

# switch on the Azure DSVM.

AzureSMR::azureStartVM(azureActiveContext = sc, resourceGroup = RG, vmName = vm_name)

AzureSMR::azureVMStatus(sc, vmName = vm_name)

# -------------------------------------------------------------------------
# R interface configuration
# -------------------------------------------------------------------------

source("rInterfaceObject.R")

interface <- new("rInterface")

# Set the interface.
interface <- riSet(object = interface,
                   remote = vm_url,
                   user = USER
)

# Configure the interface.
interface <- riConfig(object = interface, 
                      machine.list = vm_name, 
                      data = DATA3,
                      dns.list = vm_url, 
                      machine.user = USER,
                      context = "localParallel")

# Create a new worker script.
script_path <- "."
script_title <- "worker.R"
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

AzureSMR::azureStopVM(azureActiveContext = sc, resourceGroup = RG, vmName = vm_name)