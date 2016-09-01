########################################################################
# THIS ONE IS WORKING TO CREATE A Linux DSVM
#
# Code originally provided by Alan to try out 160720 for creating
# Linux DSVMs. 160722 failing at present. Alan suggests could be that
# RABC access created at resource group level rather than subscription
# level (probably) and so can only operate on that specific resource
# group.

# These are the libraries required for the experiment.

library(AzureSM)
library(httr)
library(plyr)
library(jsonlite)
library(XML)
library(magrittr)
library(dplyr)
library(stringr)

# Paste your TID/CID/KEY info here.
AzureActiveContext <- new("AzureContext")
SetAzureActiveContext(
  TID = "72f988bf-86f1-41af-91ab-2d7cd011db47",
  CID = "5070f69d-5299-43c4-920c-a4de19f6ea6c",
  KEY = "gISaoqGu4zNPnrNkvPIoYTmaAVbs4Izt4VCFwIs48yg="
)
AzureAuthenticate()

# List resource groups and VMs available under the subscription.
AzureListRG()$Name
AzureListAllRecources()

# Create a new resource group (doesn't work?).
# AzureCreateResourceGroup(AT = AzureActiveContext@Token,
#                          SUBID = AzureActiveContext@SubscriptionID,
#                          Location = "East Asia", 
#                          ResourceGroup = "linuxds_<yourname>", 
#                          Verbose = T)
# RG <- "linuxds_<yourname>"
RG <- "dsvm"

# Set up the parameter list template for the virtual machines. 
PARAM <- str_c('"parameters": ',
               '{"virtualMachines_newdsvm_adminPassword": {"value": "admin"},',
               ' "virtualMachines_newdsvm_name":          {"value": "myvm"},',
               ' "networkInterfaces_newdsvm161_name":     {"value": "myvmnic"},',
               ' "networkSecurityGroups_newdsvm_nsg_name":    {"value": "myvmsg"},',
               ' "publicIPAddresses_newdsvm_ip_name":        {"value": "myvmip"},',
               ' "virtualNetworks_dsvm_vnet_name":        {"value": "myvmvnet"},',
               ' "storageAccounts_dsvmdisks490_name":          {"value": "myvmsa"}}')

# Set up for looping through nachine creation.
NumVMs <- 1
Dep    <- "awdeploy"

# A general template JSON file.
# tempURLSSH <- "https://raw.githubusercontent.com/yueguoguo/azure_linuxdsvm/master/template.json" # SSH template (modify the public key region and host the new json file on web)
tempURLSSH <- "https://raw.githubusercontent.com/yueguoguo/azure_linuxdsvm/master/test.json"

# ################# Do your manipulation on the JSON file here with the code.
# rawjson <- readLines(tempURLSSH, warn = "F")
# rd <- fromJSON(rawjson)
# rd$resources$properties$osProfile$linuxConfiguration$ssh$publicKeys[[1]] <- c("path_to_your_own_public_key", "your_own_public_key")
# newjson <- toJSON(rd)
# write(newjson, "template.json") # Save the generated JSON file onto your remote host.
# #################

for(i in 1:NumVMs)
{
  Sys.sleep(5)

  P2   <- gsub("myvm", paste("myvm", sprintf("%02d", i), sep = ""), PARAM)
  Dep1 <- str_c(Dep, i)

  AzureDeployTemplate(ResourceGroup=RG,
                      DeplName=Dep1,
                      TemplateURL=tempURLSSH,
                      ParamJSON=P2,
                      Mode="ASYNC")
}

# Check the status of VMs in the resource group.
AzureListVM(ResourceGroup=RG)[c("Name","State")]