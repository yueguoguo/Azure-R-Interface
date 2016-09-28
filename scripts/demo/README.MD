** Prerequisites
* Azure account subscription.
* Application in Azure Active Directory with allowed access to the resource group.
* SSH toolkit.
** Description of the scripts in folder.
* deployVirtualmachineSSH.R
Demo script for firing up multiple VMs.
* jsonGen.R
Generate template json file for custom deployment.
* sshSetup.R
Demo script for setting up SSH for VM cluster.
* rInterfaceObject.R
S4 class and method of rInterface.
* main.R
Demo script of using rInterface for executing R script on cluster.
* script_parallel.R
Demo script to be executed on cluster.
** Instructions on demo
* Edit deployVirtualMachineSSH.R with account confidential and VM setups, and run it for firing up VMs.
* Run sshSetUp.R to set up the SSH environment for the VM cluster. 
* Write the R script that to remotely executed on VM cluster. 
* Customize main.R script with specified VM cluster, remote R script, and compute context set up, and run it.
