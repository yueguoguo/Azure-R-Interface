########################################################################
# SSH setup for parallel computation on DSVMs
# ----------------------------------------------------------------------
# AUTHORS:            Zhang Le, Graham Williams.
# CONTRIBUTORS:       Zhang Le, Graham Williams.
# DATE OF CREATION:   09-08-2016
# DEPARTMENT:         IMML & ADS Asia
# COMPANY:            Microsoft
########################################################################
# ----------------------------------------------------------------------
# Global variables
# ----------------------------------------------------------------------
VM_NUM        <- # number of virtual machines. 
VM_BASE       <- # prefix of the virtual machines. 
VM_USERNAME   <- # user names for the virtual machines.
RG            <- # resource group. NOTE: should be manually created.
TID           <- # tenant ID. NOTE: obtained in creating app in Active Directory.
CID           <- # client ID. NOTE: obtained in creating app in Active Directory.
KEY           <- # user key. NOTE: obtained in creating app in Active Directory.
  
# ----------------------------------------------------------------------
# Initial system check and setup
# ----------------------------------------------------------------------
ifelse (identical(.Platform$OS.type, "windows"), HOME_DIR <- normalizePath(paste(Sys.getenv("HOME"), "/../", sep = ""), winslash = "/"), HOME_DIR <- Sys.getenv("HOME"))

# To avoid pop-up in first time ssh login.
writeLines(sprintf("**NOTE**: Switch off key verification on local machine, add the following to ~/.ssh/config:
                  Host *.<location_of_the_vm>.cloudapp.azure.com
                    StrictHostKeyChecking no"))
shell(paste("ssh-keygen -y -f ", HOME_DIR, ".ssh/id_rsa > ./id_rsa.pub", sep = "")) 
ifelse(identical(.Platform$OS.type, "windows"), 
       system(paste("xcopy /f ", shQuote(paste(HOME_DIR, ".ssh/id_rsa", sep = ""), type = "cmd"), " ", shQuote(".", type = "cmd"), sep = "")),
       system("cp ~/.ssh/id_rsa ."))

# ----------------------------------------------------------------------
# SSH Setup for the Created DSVMs
# ----------------------------------------------------------------------
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

vmnames <- paste(rep(VM_BASE, VM_NUM), sprintf("%03d", 1:VM_NUM), sep = "")
dns.name.list <- paste(vmnames, location, ".cloudapp.azure.com", sep = "")

for (vm in dns.name.list)
{
  # distribute the key pair to all nodes.
  system(sprintf("scp ./id_rsa %s@%s:.ssh/", VM_USERNAME, vm))
  system(sprintf("scp ./id_rsa.pub %s@%s:.ssh/", VM_USERNAME, vm))
  
  sh <- writeChar(c("cat .ssh/id_rsa.pub > .ssh/authorized_keys\n",
                    paste("echo Host *.", location, ".cloudapp.azure.com >> ~/.ssh/config\n", sep = ""),
                    paste("echo StrictHostKeyChecking no >> ~/.ssh/config\n", sep = ""),
                    paste("echo UserKnownHostsFile /dev/null >> ~/.ssh/config\n", sep = ""),
                    "chmod 600 ~/.ssh/config\n"), con = "./shell_script")
  
  system(sprintf("scp shell_script %s@%s:~", VM_USERNAME, vm), show.output.on.console = FALSE)
  system(sprintf("ssh -l %s %s 'chmod +x ~/shell_script'", VM_USERNAME, vm), show.output.on.console = FALSE)
  system(sprintf("ssh -l %s %s '~/shell_script'", VM_USERNAME, vm), show.output.on.console = FALSE)
}

# Clean up.
file.remove("./id_rsa", "./id_rsa.pub", "./shell_script")
