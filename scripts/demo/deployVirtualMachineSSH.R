########################################################################
# Parallel R On Azure Data Science Virtual Machines
# ----------------------------------------------------------------------
# AUTHORS:            Le Zhang, Graham Williams.
# CONTRIBUTORS:       Le Zhang, Graham Williams, Alan Weaver.
# DATE OF CREATION:   20160901
# DEPARTMENT:         IMML & ADS Asia
# COMPANY:            Microsoft
########################################################################

library(AzureSMR)
library(httr)
library(plyr)
library(jsonlite)
library(XML)
library(magrittr)
library(dplyr)
library(stringr) # XXXX WHY str_c rather than paste?

# ----------------------------------------------------------------------
# Global Variables
# ----------------------------------------------------------------------

VM_NUM        <- 5                               # Number of virtual machines. 
VM_BASE       <- str_c("vm", sample(letters, 1)) # Prefix of virtual machines. 
VM_USERNAME   <- Sys.info()['user']              # User names for virtual machines.

source("settings.R")

TEMPLATES     <- paste0("https://raw.githubusercontent.com/",
                        "yueguoguo/azure_linuxdsvm/master/templates/")
  
if (length(VM_USERNAME) != VM_NUM)
  error("Assign correct number of user names to VMs.")
  
# ----------------------------------------------------------------------
# Authentication
# ----------------------------------------------------------------------

sc <- createAzureContext(tenantID=TID, clientID=CID, authKey=KEY)
# dumpAzureContext(sc)

# List resource groups and VMs available under the subscription.

rg.list  <- AzureListRG(sc)
location <- as.character(rg.list %>% filter(Name == RG) %>% select(Location))

# List all the subscriptions.

AzureListSubscriptions(sc)

# List VMs in the resource group.

AzureListVM(sc, ResourceGroup=RG)

# Stop and start a VM.

AzureStopVM(AzureActiveContext=sc, ResourceGroup=RG, VMName=)
AzureStartVM(AzureActiveContext=sc, ResourceGroup=RG, VMName=)

# ----------------------------------------------------------------------
# Provision Multiple DSVM With Custom Settings
# ----------------------------------------------------------------------

# Load the general template and parameter json files.

param <- readLines(paste0(TEMPLATES, "parameters_ssh.json"))
templ <- readLines(paste0(TEMPALTES, "template_ssh.json"))

# Name the VMs.
                   
vmnames <- paste0(rep(VM_BASE, VM_NUM), sprintf("%03d", 1:VM_NUM))

source("./scripts/jsonGen.R")

for(i in 1:VM_NUM)
{
  # Upate the template and parameter json file.
  
  temp.json <- jsonGen(templ,
                       dns.label=vmnames[i],
                       user.name=ifelse(length(VM_USERNAME) == 1,
                                        VM_USERNAME, 
                                        VM_USERNAME[i])
                       public.key=VM_PUBKEY) %>% str_c(collapse="")

  para.json <- gsub("default", vmnames[i], param) %>% str_c(collapse="")
  
  dname <- paste0(VM_BASE, "dpl", as.character(i))
  
  AzureDeployTemplate(AzureActiveContext=sc,
                      ResourceGroup=RG,
                      DeplName=dname,
                      TemplateJSON=temp.json,
                      ParamJSON=para.json, 
                      Mode="AYNC")
  
  # Error return codes and possible root-causes.
  # 200/201/202       Successful. VM will be deployed and there is no error.
  # 403               VM will not be deployed and there are some errors.
  #                   - Values in the template are not matched with those in the parameter.
  #                   - Unrecognized values in the template or parameter files.
}
