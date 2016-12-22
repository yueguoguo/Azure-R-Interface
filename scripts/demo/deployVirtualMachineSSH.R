########################################################################
# Script to Deploy Azure Data Science Virtual Machines
# ----------------------------------------------------------------------
# Authors:       Le Zhang, Graham Williams.
# Contributors:  Le Zhang, Graham Williams, Alan Weaver.
# Creation Date: 20160901
# Department:    ADS Asia Pacific
# Company:       Microsoft
########################################################################

library(AzureSMR)
library(magrittr)
library(dplyr)

# ----------------------------------------------------------------------
# Global Variables
# ----------------------------------------------------------------------

VM_NUM      <- 5                                # Number of virtual machines. 
VM_BASE     <- paste0("vm", sample(letters, 1)) # Prefix of virtual machines. 
VM_USERNAME <- Sys.info()['user']               # User names for virtual machines.

LOCAL_SETTINGS <- paste0("settings_", Sys.info()['user'], ".R")
if (file.exists(LOCAL_SETTINGS))
{
  source(LOCAL_SETTINGS)
} else {
  source("settings.R")
}
# VM_PUBKEY <- # OpenSSH compatible public key.
# RG        <- # Resource group. NOTE: should be manually created.
# LOC       <- # Data centre location for new resource group.
# TID       <- # Tenant ID from app creation in Active Directory.
# CID       <- # Client ID from app creation in Active Directory.
# KEY       <- # User key from app creation in Active Directory.

TEMPLATES     <- paste0("https://raw.githubusercontent.com/",
                        "yueguoguo/azure_linuxdsvm/master/templates/")

# Condition check.

if (! length(VM_USERNAME) %in% c(1, VM_NUM))
  stop("The AzureSMR Interface requires 1 or ", VM_NUM,
       " (number of VMs) user names.")
  
# ----------------------------------------------------------------------
# Authentication
# ----------------------------------------------------------------------

ac <- createAzureContext(tenantID=TID, clientID=CID, authKey=KEY) %T>% print()

# Test the connection by listing all available subscriptions.

azureListSubscriptions(ac)

# ----------------------------------------------------------------------
# Resource Group
# ----------------------------------------------------------------------

# We can create a new resource group for this run and then delete all
# resources once we are finished by deleting this resource
# group. Check first if it already exists. If so use it otherwise
# create the new resource group at the nominated data centre.

resource_groups <- azureListRG(ac) %>% select(name) %>% '[['(1) %T>% print()

RG

# Creating a resource group is instantaneous.

if (! RG %in% resource_groups)
{
  azureCreateResourceGroup(ac, resourceGroup=RG, location=LOC)
}

# List VMs in the resource group.

azureListVM(ac, resourceGroup=RG)

# ----------------------------------------------------------------------
# Provision Multiple DSVM With Custom Settings
# ----------------------------------------------------------------------

# Load the general template and parameter json files.

param <- readLines(paste0(TEMPLATES, "parameters_ssh.json"))
templ <- readLines(paste0(TEMPLATES, "template_ssh.json"))

# Name the VMs.
                   
vmnames <- paste0(rep(VM_BASE, VM_NUM), sprintf("%03d", 1:VM_NUM)) %T>% print()

# Support function for manipulating the JSON data.

source("jsonGen.R")

for(i in 1:VM_NUM)
{
  # Upate the template and parameter json file.
  
  temp_json <- jsonGen(templ,
                       dns.label=vmnames[i],
                       user.name=ifelse(length(VM_USERNAME) == 1,
                                        VM_USERNAME, 
                                        VM_USERNAME[i]),
                       public.key=VM_PUBKEY) %>% paste0(collapse="")

  # To print this use jsonlite::prettify(temp_json)

  para_json <- gsub("default", vmnames[i], param) %>% paste0(collapse="")

  # jsonlite::prettify(para_json)

  dname <- paste0(VM_BASE, "dpl", as.character(i))
  
  azureDeployTemplate(azureActiveContext=ac,
                      resourceGroup=RG,
                      deplname=dname,
                      templateJSON=temp_json,
                      paramJSON=para_json, 
                      mode="Async")
}

# Error return codes from azureDeployTemplate and possible root-causes.
#
# 200/201/202 Successful. VM will be deployed and there is no error.
#
# 403 VM will not be deployed as there are errors:
#
#     - Values in the template are not matched with those in the
#       parameter.
#
#     - Unrecognized values in the template or parameter files.

# Check on the status.

for (i in seq_along(vmnames))
  azureVMStatus(azureActiveContext=ac, resourceGroup=RG, vmName=vmnames[i])

# Example to stop and start a VM.

azureVMStatus(azureActiveContext=ac, resourceGroup=RG, vmName=vmnames[1])
azureStopVM(azureActiveContext=ac, resourceGroup=RG, vmName=vmnames[1])
azureStartVM(azureActiveContext=ac, resourceGroup=RG, vmName=vmnames[1])

# Once we have finished with the VMs we delete the resource group.

azureDeleteResourceGroup(ac, resourceGroup=RG)
