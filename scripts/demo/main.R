########################################################################
# "MAIN" script to submit parallel experiment scripts to DSVMs.
# ----------------------------------------------------------------------
# AUTHORS:            Zhang Le.
# CONTRIBUTORS:       Zhang Le, Graham Williams, Alan Weaver.
# DATE OF CREATION:   09-08-2016
# DEPARTMENT:         IMML & ADS
# COMPANY:            Microsoft
########################################################################

library(AzureSM)
library(httr)
library(plyr)
library(jsonlite)
library(XML)
library(magrittr)
library(dplyr)
library(stringr)

source("./scripts/rInterfaceObject.R")

# Azure account sign-in constants
RG            <- # resource group. NOTE: should be manually created.
TID           <- # tenant ID. NOTE: obtained in creating app in Active Directory.
CID           <- # client ID. NOTE: obtained in creating app in Active Directory.
KEY           <- # user key. NOTE: obtained in creating app in Active Directory.

# Authenticate Azure account.
sc <- CreateAzureContext()
SetAzureContext(sc,
                TID = TID,
                CID = CID,
                KEY = KEY)
# DumpAzureContext(sc)
AzureAuthenticate(sc)

# List resource groups and VMs available under the subscription.
rg.list <- AzureListRG(sc)
location <- as.character(rg.list %>% filter(Name == RG) %>% select(Location))

vm.list <- AzureListVM(ResourceGroup = RG)
vm.names <- as.character(vm.list$Name)
vm.dns.list <- paste(vm.names, "dns.", location, ".cloudapp.azure.com", sep = "")

# Select 1/3 of the list for experiment.
set.seed(123)
indx <- sample(1:length(vm.names), trunc(length(vm.names)/3))
vm.used.list <- vm.names[indx]
vm.dns.used.list <- vm.dns.list[indx]

# Select one to be the master node while some others to be the slaves.
master <- vm.dns.used.list[1]
slaves <- vm.dns.used.list[-1]

# Create a new interface
interface <- new("rInterface")

interface <- ri.set(object = interface,
                          remote = master,
                          user = "zl",
                          script = "./scripts/test.R")

interface <- ri.config(object = interface, 
                       machine.list = vm.used.list, 
                       dns.list = vm.dns.used.list, 
                       machine.user = "zl",
                       master = master, 
                       slaves = slaves,
                       context = "clusterParallel")

ri.dump(interface)

ri.upload(interface)

ri.execute(object = interface,
              roptions = "--verbose",
              verbose = TRUE)
