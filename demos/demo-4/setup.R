library(AzureDSR)
library(AzureSMR)
library(magrittr)
library(dplyr)

source("../../../../adsap_github/misc/confidential.R")

# Parameters for this script: the name for the new resource group and
# its location across the Azure cloud. The resource name is used to
# name the resource group that we will create transiently for the
# purposes of this script.

RG  <- "new_dsvm2"  # Will be created if not already exist then kill.
LOC <- "southeastasia"   # Where the resource group (resources) will be hosted.

# Create names for the VMs.

COUNT <- 7                # Number of VMs to deploy.
BASE  <- 
  runif(4, 1, 26) %>%
  round() %>%
  letters[.] %>%
  paste(collapse="") %T>% print()
USER <- Sys.info()[['user']]
LDSVM <- paste0(BASE, sprintf("%03d", 1:COUNT)) %T>% print()
LUSER <- paste0("u", sprintf("%03d", 1:COUNT)) %T>% print()

# Connect to the Azure subscription and use this as the context for
# all of our activities.

context <- createAzureContext(tenantID=TID, clientID=CID, authKey=KEY)

# Check if the resource group already exists. Take note this script
# will not remove the resource group if it pre-existed.

rg_pre_exists <- existsRG(context, RG, LOC) %T>% print()

# Create Resource Group

if (! rg_pre_exists)
{
  # Create a new resource group into which we create the VMs and
  # related resources. Resource group name is RG. 
  
  # Note that to create a new resource group one needs to add access
  # control of Active Directory application at subscription level.
  
  azureCreateResourceGroup(context, RG, LOC)
  
}

# Create a Cluster

cluster <- deployDSVMCluster(context, 
                             resource.group=RG, 
                             location=LOC, 
                             hostnames=BASE,
                             usernames=USER, 
                             pubkeys=PUBKEY,
                             count=COUNT)

for (i in 1:COUNT)
{
  vm <- cluster[i, "name"]
  fqdn <- cluster[i, "fqdn"]
  
  cat(vm, "\n")
  
  operateDSVM(context, RG, vm, operation="Check")
  
  # Send a simple system() command across to the new server to test
  # its existence. Expect a single line with an indication of how long
  # the server has been up and running.
  
  cmd <- paste("ssh -q",
               "-o StrictHostKeyChecking=no",
               "-o UserKnownHostsFile=/dev/null\\\n   ",
               fqdn,
               "uptime") %T>%
               {cat(., "\n")}
  cmd
  system(cmd)
  cat("\n")
}

vm <- AzureSMR::azureListVM(context, RG)

AzureDSR::operateDSVM(context, RG, vm$name, operation="Start")

machines <- unlist(vm$name)
dns_list <- paste0(machines, ".", LOC, ".cloudapp.azure.com")
master <- dns_list[1]
slaves <- dns_list[-1]

AzureDSR::executeScript(context=context, 
                        resourceGroup=RG, 
                        machines=machines, 
                        remote=master, 
                        user=USER, 
                        script="./learning_process.R", 
                        master=master, 
                        slaves=slaves, 
                        computeContext="clusterParallel")

AzureDSR::operateDSVM(context, RG, vm$name, operation="Stop")
