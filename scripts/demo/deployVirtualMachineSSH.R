########################################################################
# Parallel R On Azure Data Science Virtual Machines
# ----------------------------------------------------------------------
# AUTHORS:            Le Zhang, Graham Williams.
# CONTRIBUTORS:       Le Zhang, Graham Williams, Alan Weaver.
# DATE OF CREATION:   09-01-2016
# DEPARTMENT:         IMML & ADS Asia
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

# ----------------------------------------------------------------------
# Global variables
# ----------------------------------------------------------------------
VM_NUM        <- # number of virtual machines. 
VM_BASE       <- # prefix of the virtual machines. 
VM_USERNAME   <- # user names for the virtual machines.
VM_PUBKEY     <- # OpenSSH compatible public key 
RG            <- # resource group. NOTE: should be manually created.
TID           <- # tenant ID. NOTE: obtained in creating app in Active Directory.
CID           <- # client ID. NOTE: obtained in creating app in Active Directory.
KEY           <- # user key. NOTE: obtained in creating app in Active Directory.

if (length(VM_USERNAME) != VM_NUM) error("Assign correct number of user names to VMs.")
  
# ----------------------------------------------------------------------
# Authentication.
# ----------------------------------------------------------------------
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

# List all the subscriptions.
AzureListSubscriptions(sc)

# List VMs in the resource group.
AzureListVM(sc, ResourceGroup = RG)

# Stop and start a VM.
AzureStopVM(AzureActiveContext = sc, ResourceGroup = RG, VMName = )
AzureStartVM(AzureActiveContext = sc, ResourceGroup = RG, VMName = )

# ----------------------------------------------------------------------
# Provision Multiple DSVM With Custom Settings
# ----------------------------------------------------------------------
# Load the general template and parameter json files.
param <- readLines("https://raw.githubusercontent.com/yueguoguo/azure_linuxdsvm/master/templates/parameters_ssh.json")
templ <- readLines("https://raw.githubusercontent.com/yueguoguo/azure_linuxdsvm/master/templates/template_ssh.json") # template url.

# Name the VMs.
vmnames <- paste(rep(VM_BASE, VM_NUM), sprintf("%03d", 1:VM_NUM), sep = "")

source("./scripts/jsonGen.R")

for(i in 1:VM_NUM) {
  # Upate the template and parameter json file.
  temp.json <- jsonGen(templ,
                       dns.label = vmnames[i],
                       user.name = ifelse(length(VM_USERNAME) == 1,
					  VM_USERNAME, 
					  VM_USERNAME[i])
                       public.key = VM_PUBKEY) %>% str_c(collapse = "")
  para.json <- gsub("default", vmnames[i], param) %>% str_c(collapse = "")
  
  dname <- paste(VM_BASE, "dpl", as.character(i), sep = "")
  
  AzureDeployTemplate(AzureActiveContext = sc,
                      ResourceGroup = RG,
                      DeplName = dname,
                      TemplateJSON = temp.json,
                      ParamJSON = para.json, 
                      Mode = "AYNC")
  # Error return codes and possible root-causes.
  # 200/201/202       Successful. VM will be deployed and there is no error.
  # 403               VM will not be deployed and there are some errors.
  #                   - Values in the template are not matched with those in the parameter.
  #                   - Unrecognized values in the template or parameter files.
}
