# Setting up your Lab Environment

In this section we will learn how to set-up our ***Build-Your-Own-Lab Environments***. As shown in the intro, we will use a script that is based off of the AutomatedLab framework to create 3 machines - ContosoDC, AdminPC, and ClientPC. In addition to creating these machines, we also get many of the dependencies pre-installed, such as the Domain Controller already set up in ContosoDC, SQL Server and Office ProPlus in AdminPC along with **Azure Information Protection Unified Labeling Client**, and ClientPC again with Office ProPlus and the **Azure Information Protection Unified Labeling Client**. 

## Where to Begin

First you need to decide between the two options for BYOL which is either creating your machines through your local HyperVisor or with Microsoft Azure. 

You can find the HyperV Script [here](AIPBYOL-HyperV.ps1) and the Azure script [here](AIPBYOL-Azure.ps1).

## AutomatedLab Framework

The AutomatedLab Framework (https://github.com/AutomatedLab) was used to create this lab set-up. As a prequisite for getting started, you must use the following PowerShell Commands on your PowerShell ISE as administrator to have the right modules to run the rest of the lab:
	```PowerShell
	Install-PackageProvider Nuget -Force
	Install-Module AutomatedLab -AllowClobber
	New-LabSourcesFolder -Drive C
	Install-Module Az
	...
The First command 
