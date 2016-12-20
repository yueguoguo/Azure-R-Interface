# INSTRUCTIONS
## Prerequisites
* Azure account subscription.
* Application in Azure Active Directory with allowed access to the resource group.
* SSH toolkit.

## Description of the scripts in folder.
* `deployVirtualmachineSSH.R`
Demo script for firing up multiple VMs.
* `jsonGen.R`
Generate template json file for custom deployment.
* `sshSetup.R`
Demo script for setting up SSH for VM cluster.
* `rInterfaceObject.R`
S4 class and method of rInterface.
* `master_clusterParallelSweeping.R`
Master script that specifies the experiment environment such as header
node, compute context, etc., for the analytical jobs. 
* `worker_clusterParallelSweeping.R`
The worker script contains the actual analytics. A predictive
maintenance use case is demonstrated here.

## Instructions on demo
1. Edit `deployVirtualMachineSSH.R` with account confidential and VM setups, and run it for firing up VMs.
2. Run `sshSetUp.R` to set up the SSH environment for the VM cluster. 
3. Write the R script that to remotely executed on VM cluster. 
4. Customize main.R script with specified VM cluster, remote R script, and compute context set up, and run it.

