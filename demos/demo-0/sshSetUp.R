########################################################################
# SSH setup for parallel computation on DSVMs
# ----------------------------------------------------------------------
# AUTHORS:            Zhang Le, Graham Williams.
# CONTRIBUTORS:       Zhang Le, Graham Williams.
# DATE OF CREATION:   20160908
# DEPARTMENT:         ADS Asia Pacific
# COMPANY:            Microsoft
########################################################################

# ----------------------------------------------------------------------
# Global Variables
# ----------------------------------------------------------------------

VM_NUM        <- # number of virtual machines. 
VM_BASE       <- # prefix of the virtual machines. 
VM_USERNAME   <- # user names for the virtual machines.
RG            <- # resource group. NOTE: should be manually created.
TID           <- # tenant ID. NOTE: obtained in creating app in Active Directory.
CID           <- # client ID. NOTE: obtained in creating app in Active Directory.
KEY           <- # user key. NOTE: obtained in creating app in Active Directory.
  
# ----------------------------------------------------------------------
# Initial System Check and Setup
# ----------------------------------------------------------------------

HOME_DIR <- ifelse(identical(.Platform$OS.type, "windows"),
                   normalizePath(paste0(Sys.getenv("HOME"), "/../"), winslash = "/"),
                   Sys.getenv("HOME"))

# To avoid pop-up in first time ssh login.

writeLines(sprintf("**NOTE**: Switch off key verification on local machine, add the following to ~/.ssh/config:
                  Host *.<location_of_the_vm>.cloudapp.azure.com
                    StrictHostKeyChecking no"))
shell(paste0("ssh-keygen -y -f ", HOME_DIR, ".ssh/id_rsa > ./id_rsa.pub")) 
ifelse(identical(.Platform$OS.type, "windows"), 
       system(paste0("xcopy /f ", shQuote(paste0(HOME_DIR, ".ssh/id_rsa"), type = "cmd"),
                     " ", shQuote(".", type = "cmd"))),
       system("cp ~/.ssh/id_rsa ."))

# ----------------------------------------------------------------------
# SSH Setup for Created DSVMs
# ----------------------------------------------------------------------

# Authenticate Azure account.

sc <- createAzureContext(tenantID=TID, clientID=CID, authKey=KEY)

# List resource groups and VMs available under the subscription.

rg_list <- AzureListRG(sc)
location <- as.character(rg_list %>% filter(Name == RG) %>% select(Location))

vmnames <- paste0(rep(VM_BASE, VM_NUM), sprintf("%03d", 1:VM_NUM))
dns_name_list <- paste0(vmnames, location, ".cloudapp.azure.com")

for (vm in dns_name_list)
{
  # Distribute the key pair to all nodes.
  
  system(sprintf("scp ./id_rsa %s@%s:.ssh/", VM_USERNAME, vm))
  system(sprintf("scp ./id_rsa.pub %s@%s:.ssh/", VM_USERNAME, vm))
  
  sh <- writeChar(c("cat .ssh/id_rsa.pub > .ssh/authorized_keys\n",
                    paste0("echo Host *.", location, ".cloudapp.azure.com >> ~/.ssh/config\n"),
                    paste0("echo StrictHostKeyChecking no >> ~/.ssh/config\n"),
                    paste0("echo UserKnownHostsFile /dev/null >> ~/.ssh/config\n"),
                    "chmod 600 ~/.ssh/config\n"), con = "./shell_script")
  
  system(sprintf("scp shell_script %s@%s:~", VM_USERNAME, vm), show.output.on.console = FALSE)
  system(sprintf("ssh -l %s %s 'chmod +x ~/shell_script'", VM_USERNAME, vm), show.output.on.console = FALSE)
  system(sprintf("ssh -l %s %s '~/shell_script'", VM_USERNAME, vm), show.output.on.console = FALSE)
}

# Clean up.

file.remove("./id_rsa", "./id_rsa.pub", "./shell_script")
