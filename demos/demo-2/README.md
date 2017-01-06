# Introduction
This demo shows how to deploy Microsoft DSVM and Cognitive Services to predict employee churn. 
 
## Prerequisites
* R >= 3.3.1 
* AzureSMR and cognitiveR packages.
* Azure account subscription.
* Application in Azure Active Directory with allowed access to the resource group.
* SSH toolkit.
* Azure Cognitive Service subscription.

## Description of the scripts in folder.
* `settings.R`
Global variables such as login crendentials and environmental setups.
* `exploration.R`
Exploratory study on the data set.
* `master.R`
Master script that manages Azure resources.
* `worker.R`
Workder script that contains the actual experimental analytics.

## Instructions on demo
1. Follow the steps in [AzureSMR](https://github.com/Microsoft/AzureSMR) and [cognitiveR](https://github.com/yueguoguo/Azure-R-Interface/tree/master/utils/cognitiveR) website to finish subscritions.
2. Modify `settings.R` script with correct information.
3. Run `exploration.R` for exploratory studies on the sample data of HR attrition.
4. Edit and run `master.R` and `worker.R` scripts for experimental analytics on Azure data science virtual machine with specified computing context.
