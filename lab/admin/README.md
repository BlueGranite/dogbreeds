# Azure Machine Learning Service

## Administration Tutorial

The purpose of this tutorial is to guide Azure administrators and data science team managers overseeing Azure Machine Learning (AzureML) workspaces for enterprise deployments. AzureML empowers teams to collaboratively build, train, and deploy machine learning models.

One of the key goals is to restrict teams and users from creating compute targets as a cost control measure.

This tutorial will cover automation and management related to:

- Creating user roles, such as a data scientist, with defined permissions related to compute resources

- Creating resource groups for AzureML-related resources

- Creating AzureML workspaces

- Assigning user permissions at various scopes, such as subscription or workspace

Important concepts:

- AzureML workspaces allow collaboration through data set and model registration

- Understand the default roles: owner, contributor, and reader … compared to custom role of data scientist

- How to enforce compute resource quota across team members

This guide will focus on roles for two personas: *Admin* and *Data Scientist*.

Admin persona:

- Create and manage access to resource groups and AzureML workspaces for data science teams

- Create and allocate compute resources within quota (monitor and report)

- Create and manage shared datastores for workspace artifacts and experiment data

- Manage spend on compute resources by creating custom roles with access controls

- Provide shared resource information (such as secure data stores) to team members

- Provide AzureML training resources to team members

Data Scientist persona:

- Use workspace to run machine learning experiments, especially at scale with remote compute resources

- Use dedicated and shared Azure data sources for collaborative model building

- Cannot request compute quota

- Cannot create or modify AzureML compute resources

- Cannot create support tickets

Assumptions:

- Users of this guide will already have an assigned subscription ID and compute quota

### Overview of activities performed in this setup:

1. Access the Azure Command Line Interface (CLI) in the Azure Portal and clone the file repository

2. Setup Azure ML workspace using a provided template script. This script includes creating a custom ‘Data Scientist’ role.  

3. Setup compute resources using a provided template script.  

4. Additional Considerations for Workspace Design.

**IMPORTANT:** The admin scripts run in Bash.

---------

### Activities for Setup:

#### 1. Access the Azure Command Line Interface (CLI) in the Azure Portal and clone the file repository

The Azure CLI is a command-line tool providing a great experience for managing Azure resources. The CLI is designed to make scripting easy, query data, support long-running operations, and more.

Log into the Azure Portal and click on the cloud shell icon in the top right panel:

[IMAGE HERE]

[Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/persisting-shell-storage) machines are temporary and require an Azure File share to be mounted as `clouddrive`. On the first launch of Cloud Shell the following items are automatically created for this purpose. If prompted to create resources for file share enter yes.

[IMAGE HERE][IMAGE HERE]

#### 2. Setup AzureML Workspaces

The workspace is the top-level resource for Azure Machine Learning service. For ideas on workspace organization see the following two links: [What is an Azure Machine Learning service workspace?](https://docs.microsoft.com/en-us/azure/machine-learning/service/concept-workspace) and [How Azure Machine Learning service works: Architecture and concepts](https://docs.microsoft.com/en-us/azure/machine-learning/service/concept-azure-machine-learning-architecture). A workspace provides a centralized place to work with the artifacts created while using Azure Machine Learning service. These artifacts include metrics and logs associated with a training run. This aids in determining the best model when testing multiple options. A workspace can be created in multiple ways including through a Resource Manager template, the Azure Portal, and Azure CLI. For this setup, a template script newamllabworkspace_azurecli_yml.sh is provided in the script repository. To access the template scripts, clone the git directory: [https://github.com/BlueGranite/dogbreeds/tree/colby](https://github.com/BlueGranite/dogbreeds/tree/colby) To clone a git directory in the Azure CLI use the following command:

`git clone --single-branch --branch colby https://github.com/BlueGranite/dogbreeds.git`

This workspace template script receives the required workspace creation and naming parameters such as subscription id, department, team, region, and admin from a configuration file. The user has the option to either customize the configuration file using `custom_config.yml` or retain the already established configurations in `config.yml`. To add custom configurations:

- Open the `custom_config.yml` in the CLI editor. This file, along with the other required template files, are located in the downloaded directory from above in lab/admin

- Update the parameters to their desired values

- The parameter `custom_name` is optional but can be used to suppress Microsoft’s automatic, conventional naming scheme of concatenating the other parameters. This parameter is useful in ensuring multiple workspaces with common names are not trying to be created which would result in an error. *Add in custom naming recommendations chart*

- Save the updated configuration file.

Run the workspace creation script by using `bash newamllabworkspace_azurecli_yml.sh` or `bash newamllabworkspace_azurecli_yml.sh custom_config.yml`. The first bash command is used if no configuration customizations were created. The workspace script will use the parameters from the config.yml file. The second bash command option uses the customized configurations in the `custom_config.yml` file.

Enter ‘`y`’ to continue. A prompt will appear to follow the Microsoft link to login with the provided authentication code.

[IMAGE HERE]

This will create the workspace along with the necessary resources.

[IMAGE HERE]

By navigating to the specified subscription and resource group in the Azure portal window all the resources created can be viewed:

[IMAGE HERE]

Summary of resources created with the workspace script:

| Resource            | User                                                                                                                            |
|:-------------------:|:-------------------------------------------------------------------------------------------------------------------------------:|
| Resource Group      | Reader                                                                                                                          |
| Workspace           | Data Scientist                                                                                                                  |
| Storage Account     | Storage Blob Data (2 accounts one for data and one for dev work)                                                                |
| Container Registry  | Contributor                                                                                                                     |
| Key Vault           | Contributor                                                                                                                     |
| App Insights        | Contributor                                                                                                                     |
| Data Scientist Role | Can use the workspace and shared resources but cannot request compute quota, modify compute resources or create support tickets |

The Data Scientist role is a currently a custom role. Users can be [assigned to this role](https://docs.microsoft.com/en-us/azure/machine-learning/service/how-to-assign-roles) within the Azure Portal.

#### 3. Setup compute resources using a provided template script.

A [compute target](https://docs.microsoft.com/en-us/azure/machine-learning/service/concept-compute-target) specifies the compute resource where a training script will be run. The target could either be on a local machine or cloud-based. Compute targets allow for an easy transition among environments without altering code.

The `newamllabcompute_azurecli_yml.sh` script creates a remote compute target accessible by the workspace.  The parameters required for the compute script include:

- Maximum number of nodes

- Priority of the node: either lowpriority or dedicated

- VM SKU: Options for this parameter can be found using the command `az vm list-sizes --location <region> --output table`

- Cluster Name: Up to 16 characters allowed

Similarly, to the workspace script, these parameters can be customized in the `custom_config.yml` file.

To run the compute script, enter `bash newamllabcompute_azurecli_yml.sh` or `bash newamllabcompute_azurecli_yml.sh custom_config.yml` (if parameter changes were made). Again, follow the Microsoft hyperlink to the login page and enter the provided authentication code.

[IMAGE HERE]

The compute parameters are displayed and pressing enter to verify the parameters are correct launches the creation of the compute target

[IMAGE HERE][IMAGE HERE]

Attributes and properties of the cluster can be viewed by navigating to the machine learning workspace and clicking on the Compute icon on the left side panel.

[IMAGE HERE]

To create additional compute in the same workspace:

- Edit the `custom_config.yml` with the new compute’s desired parameters

- The name of the new compute must be different from the existing computes

- In Azure CLI re-run the command `bash newamllabcompute_azurecli_yml.sh custom_config.yml`

#### 4. Additional Considerations for Workspace Design

· You may want to configure different user privileges across data stores using [role-based access control](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview#how-rbac-works) (RBAC). For example, an administrator may want to control access to storage with personally identifiable information and allow access to only certain members or teams within a workspace.  

· You may want to configure workspaces differently for different organizational scenarios. Common examples include team-based and project-based design. << Looking for suggestions here from Sung >>
