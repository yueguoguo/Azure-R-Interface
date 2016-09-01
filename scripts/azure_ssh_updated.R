########################################################################
# Create a cluster of DSVMs, execute R parallel, delete all resources.
#
# Pre-requisite:
#
# 1. Obtain an Azure subscription
# 2. Create a new resource group
# 3. Create an applicaiton to operate within resource group
#
# Then this script will
#
# 1. Copy a template.json to an accessible URL
# 2.
#
# Post-requisite
#
# 1. Delete all resources within the group through the portal
#
# TODO
#
# * Create new resource group dsvmgjwres01
# * Create new application dsvmgjwapp01
# * Modify template.json to refer to southeastasia
# * Modify template.json to replace linuxds4 with dsvmgjw

# These are the libraries required for the experiment and using
# AzureSM. Some are requisites for AzureSM and will not be required
# once AzureSM package is fixed.

library(AzureSM)
library(httr)
library(plyr)
library(jsonlite)
library(XML)
library(magrittr)
library(dplyr)
library(stringr)

# Constants

NUMV <- 3						# Number of virtual machines.
BASE <- "dsvmgjw"					# Used to generate resource names
RG   <- "dsvmrestmpl00"					# The resource group name
TID  <- "72f988bf-86f1-41af-91ab-2d7cd011db47"
CID  <- "fbea3b19-1eb1-464b-8f61-f808491e9bf8"
KEY  <- "yDcP26SgZsfOU9MrkcL5sOZ5BG882MraQUxAGVa1Izc="
TMPL <- "togaware.com:webapps/togaware/access"		# Location of JSON template.
URL  <- "http://togaware.com/access/template.json"

# We could manipulate the local JSON file here.

# rawjson <- readLines(tempURLSSH, warn=FALSE)
# rd <- fromJSON(rawjson)
# rd$resources$properties$osProfile$linuxConfiguration$ssh$publicKeys[[1]] <-
#   c("path_to_your_own_public_key", "your_own_public_key")
# newjson <- toJSON(rd)
# write(newjson, "template.json")

# Copy template.json to an accessible URL.

system(paste("scp template.json", TMPL))

# 160830 We would prefer to create a new resource group here but it
# doesn't work?  Currently I use app: dsvmrestmpl rg: dsvmrestmpl00
# but next time create a dsvmgjwres01 resource group and dsvmgjwapp01
# application.
#
# AzureCreateResourceGroup(AT = AzureActiveContext@Token,
#                          SUBID = AzureActiveContext@SubscriptionID,
#                          Location = "East Asia", 
#                          ResourceGroup = RG, 
#                          Verbose = T)
# 

AzureActiveContext <- new("AzureContext")
SetAzureActiveContext(TID=TID, CID=CID, KEY=KEY, ResourceGroup=RG)
AzureAuthenticate()
AzureListVM()

# List resource groups and VMs available under the subscription.

AzureListRG()$Name

# Set up the parameter list template for the virtual machines. 

PARAM <- str_c('"parameters": ',
               '{"virtualMachines_DSVM_adminPassword": {"value": "dsvmgjw@MFST"},',
               ' "virtualMachines_DSVM_name":          {"value": "dsvmgjw"},',
               ' "networkInterfaces_DSVMNIC_name":     {"value": "dsvmgjwnic"},',
               ' "networkSecurityGroups_DSVM_name":    {"value": "dsvmgjwsg"},',
               ' "publicIPAddresses_DSVM_name":        {"value": "dsvmgjwip"},',
               ' "virtualNetworks_DSVMVN_name":        {"value": "dsvmgjwvnet"},',
               ' "storageAccounts_dsvm_name":          {"value": "dsvmgjwsa"}}')

# Set up for looping through machine creation.

for(i in 1:NUMV)
{
  Sys.sleep(5)

  parm  <- gsub(BASE, paste(BASE, sprintf("%03d", i), sep = ""), PARAM)

  # WARNING dname must be not too long. 10 seems okay but 16 is not!!
  # Returns 200 from PUT instead of 201, even though deployment
  # continues.
  
  dname <- sprintf("%s%03d", BASE, i)
  
  AzureDeployTemplate(ResourceGroup=RG,
                      DeplName=dname,
                      TemplateURL=URL,
                      ParamJSON=parm,
                      Mode="ASYNC")

}

# Check the status of VMs in the resource group. WAIT UNTIL CREATED

AzureListVM(ResourceGroup=RG)[c("Name","State")]

AzureListAllRecources()

# TODO List the IP address of each VM in R CODE!!!!!!!!!!!!!!!!!!!!!

master <- "23.97.68.179"
slaves <- c("13.75.123.194", "23.97.78.144")
nodes  <- c(master, slaves)

# Setup ssh keys on servers for connection in both directions.
#
# TODO Need to add to known_hosts.

system("ssh-keygen -t rsa -N "" -f ./id_rsa")

for (vm in nodes)
{
  system(sprintf("scp id_rsa %s:.ssh/", vm))
  system(sprintf("scp id_rsa.pub %s:.ssh/", vm))
  system(sprintf("ssh %s 'cat .ssh/id_rsa.pub >> .ssh/authorized_keys'", vm))
}

system(sprintf("scp example01.R %s:", master))
system(sprintf("ssh %s Rscript example01.R", master))
