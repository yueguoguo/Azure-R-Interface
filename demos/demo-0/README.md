# Introduction 
This demonstration presents how to form a high performance cluster on top of Azure Linux Data Science Virtual Machines, and submit scalable analytical jobs to the cluster with the help of an **R Interface**. A `AzureSMR` package is used to harness Azure instances such as virtual machines all within R session - no bother from GUI interaction and PowerShell scripting. A use case on predictive maintenance is illustrated. 

## Prerequisites
* R >= 3.3
* `AzureSMR` package.
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
* `settings.R`
Global settings - ID, key, and usernames used in the other scripts.

## Instructions on demo
1. Edit `deployVirtualMachineSSH.R` with account confidential and VM setups, and run it for firing up VMs.
2. Run `sshSetUp.R` to set up the SSH environment for the VM cluster. 
