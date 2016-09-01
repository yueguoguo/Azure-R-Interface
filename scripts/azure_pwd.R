########################################################################
# THIS ONE IS WORKING TO CREATE A Linus DSVM
#
# Code originally provided by Alan to try out 160720 for creating
# Linux DSVMs. 160722 failing at present. Alan suggests could be that
# RABC access created at resource group level rather than subscription
# level (probably) and so can only operate on that specific resource
# group.

# Following is an experiment on creating Linux DSVM. The code is based on 
# the code provided by Graham 160823. The functions needed are
#
#   AzureDeleteVM()
#
#   AzureResizeVM()
#
#   AzureCreatelinuxds3cVM() - this takes minimal specs, generates the
#   templates, and sends off the request to create the virtual
#   machine.

# These are the libraries required for the experiment.

library(AzureSM)
library(httr)
library(plyr)
library(jsonlite)
library(XML)
library(magrittr)
library(dplyr)
library(stringr)

# Resource group to use. Pre-existing for now. Intent is to create a
# resource group and then to delete when finished.

RG <- "linuxds3"

# Establish an authorised connection.

# Abbreviations:
#   
#  TID (Tenant ID).
#  CID (Client ID).
#  KEY: the password for the client.

# Get all of these from the set up of new application in the active directory.

AzureActiveContext <- new("AzureContext")
SetAzureActiveContext(
  TID = "72f988bf-86f1-41af-91ab-2d7cd011db47",
  CID = "901ef9c4-32ca-4ae6-a212-44412b4c890a",
  KEY = "IyXfoQqpdSvVzJK7QcDXwoPd5XXJd8jgrNKNhC7mWpw="
)
AzureAuthenticate()

# I can list resources okay.

AzureListRG()$Name
AzureListAllRecources()
AzureListVM(ResourceGroup=RG)

# Set up the parameter list template for the virtual machines. 
# NOTE this setup is specific to a resource group.

# NOTE you have to give different values in the PARAM setup each time a deployment is performed.

PARAM <- str_c('"parameters": ',
               '{"virtualMachines_DSVM_adminPassword": {"value": "linuxdatascience@MSFT"},',
               ' "virtualMachines_DSVM_name":          {"value": "linuxds3c"},',
               ' "networkInterfaces_DSVMNIC_name":     {"value": "linuxds3c721"},',
               ' "networkSecurityGroups_DSVM_name":    {"value": "linuxds3c-sg"},',
               ' "publicIPAddresses_DSVM_name":        {"value": "linuxds3c-ip"},',
               ' "virtualNetworks_DSVMVN_name":        {"value": "linuxds3c-vnet"},',
               ' "storageAccounts_dsvm_name":          {"value": "linuxds3c650"}}')

# For simplicity, one vm is created in this experiment.
AzureDeployTemplate(ResourceGroup = RG,
		    DeplName = "linuxds3c",
        TemplateURL = "http://analyticsfiles.blob.core.windows.net/resourcetemplates/dsvmlinuxresource",
		    ParamJSON = PARAM,
		    Mode = "ASYNC")

# List the created VMs.
AzureListVM(ResourceGroup=RG)[c("Name","State")]

# # Set up for looping through nachine creation.
# 
# NumVMs <- 3
# 
# VMroot <- "vmlab"
# STroot <- "vmlab1234store"
# 
# PARAM  <- gsub("XXXXX", VMroot, PARAM)
# PARAM  <- gsub("YYYYY", STroot, PARAM)
# 
# Dep    <- "awdeploy"
# 
# TMPL.URL <- "http://analyticsfiles.blob.core.windows.net/resourcetemplates/dsvmlinuxresource"
# 
# i <- 1 # For testing.
# 
# for(i in 1:NumVMs)
# {
#   Sys.sleep(5)
# 
#   P2   <- gsub("%%%", sprintf("%03d", i), PARAM)
#   Dep1 <- str_c(Dep, i)
# 
#   AzureDeployTemplate(ResourceGroup=RG,
#                       DeplName=Dep1,
#                       TemplateURL=TMPL.URL,
#                       ParamJSON=P2,
#                       Mode="ASYNC")
# }
# 
# AzureListVM(ResourceGroup=RG)[c("Name","State")]
# 
# # AzureDeleteResourceGroup(ResourceGroup=RG, Location="North Europe")