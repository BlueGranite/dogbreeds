#!/bin/sh

## this script creates a compute context for the Azure Machine Learning service workspace using the Azure CLI

echo "ADDING COMPUTE TO A WORKSPACE"
## run this if you are starting from scratch; skip if you are continuing from newamllabworkspace.sh
read -p  "Enter the subscription ID: " SUBSCRIPTION_ID
read -p  "Enter the department name (4 chars): " DEPARTMENT_NAME
read -p  "Enter the team name (10 chars): " TEAM_NAME
read -p  "Enter the region (such as westus2 or westeurope): " LOCATION
read -p  "Enter the region abbreviation (such as w2 or we) (2 chars): " LOCATION_ABBR
read -p  "Enter the enviornment. (e.g. res, dev, or pro) (3 chars): " DEVENVIRONMENT
read -p  "Enter the admin account (e.g. user@domain.com): " TEAM_LEAD
read -p  "Enter the workspace name: " workspace_name

## run
read -p "Enter the maximum number of nodes: " NODES
read -p "Enter the priority, either lowpriority or dedicated: " PRIORITY
read -p "Enter GPU type, such as K80, P100 or CPU: " GPU_TYPE
read -p "Enter number of GPUs: 1, 2 or 4: " GPUS

resourcegroup_name=$DEPARTMENT_NAME-$TEAM_NAME-$LOCATION-$DEVENVIRONMENT
resource_name=$DEPARTMENT_NAME$TEAM_NAME$LOCATION$DEVENVIRONMENT

echo 'resourcegroup_name: '$resourcegroup_name
echo 'WORKSPACE: '$workspace_name

echo "resourcename: "$resource_name
echo "workspacename: "$workspace_name
echo "location: "$LOCATION
echo "location abbreviation: "$LOCATION_ABBR

az login
az account set --subscription $SUBSCRIPTION_ID

## validate resource group exists
resource_exists=$(az group exists --name $resourcegroup_name)
if [ $resource_exists == 'false' ]
then
	echo "resource group does not exist: " $resourcegroup_name
	exit 1
fi

GPU_TYPE="${GPU_TYPE,,}"

vm_size="STANDARD_"

if [ $GPU_TYPE == "k80" ]
then
	echo "using "$GPU_TYPE
	vm_size="STANDARD_"
    if [ $GPUS == 1 ]
	then
        $vm_size=$vm_size"NC6"
    fi
    if [ $GPUS == 2 ]
	then
        $vm_size=$vm_size"NC12"
    fi
    if [ $GPUS == 4 ]
	then
        $vm_size=$vm_size"NC24"
    fi
	echo "vm_size: "$vm_size
fi

if [ $GPU_TYPE == "p100" ]
then
	echo "using "$GPU_TYPE
	vm_size="STANDARD_"
    if [ $GPUS == 1 ]
	then
        vm_size=$vm_size"NC6s_v2"
    fi
    if [ $GPUS == 2 ]
	then
        vm_size=$vm_size"NC12s_v2"
    fi
    if [ $GPUS == 4 ]
	then
        vm_size=$vm_size"NC24s_v2"
    fi
	echo "vm_size: "$vm_size
fi

if [ $GPU_TYPE == "cpu" ]
then
	vm_size="Standard_E32s_v3"
	GPUS="0"
	echo "vm_size: "$vm_size
fi

priorityabbr=${PRIORITY:0:3}
computetarget_name=$GPU_TYPE-$GPUS"gpu-"$LOCATION_ABBR-$priorityabbr
computetarget_name=${computetarget_name:0:15}

echo "### creating compute with the following ###"
echo "computetarget_name: "$computetarget_name
echo "Maximum number of NODES: "$NODES
echo "vm_size: "$vm_size
echo "PRIORITY: "$PRIORITY
echo "resourcegroup_name: "$resourcegroup_name
echo "workspace_name: "$workspace_name
echo "TEAM_LEAD: "$TEAM_LEAD
read -p "review compute target. press the enter key to continue " -n1 -s
echo

az ml computetarget create amlcompute --name $computetarget_name \
    --max-nodes $NODES --vm-size $vm_size \
    --workspace-name $workspace_name --idle-seconds-before-scaledown 1800 \
    --vm-priority $PRIORITY --resource-group $resourcegroup_name -v \
    --admin-username $TEAM_LEAD --admin-user-password $workspace_name

az ml computetarget show --name $computetarget_name \
    --workspace-name $workspace_name --resource-group $resourcegroup_name -v

tag=$vm_size_$PRIORITY=$NODES
az resource update --resource-group $resourcegroup_name --name $workspace_name \
    --resource-type "Microsoft.MachineLearningServices/workspaces" --set tags.$tag

az ml workspace show --resource-group $resourcegroup_name --workspace-name $workspace_name

az ml computetarget list --resource-group $resourcegroup_name --workspace-name $workspace_name

echo "For your users to use in the orientation lab:"
echo "export RESOURCE_GROUP=\"$resourcegroup_name\"
export WORKSPACE=\"$workspace_name\"
export SUBSCRIPTION_ID=\"$SUBSCRIPTION_ID\"
export CLUSTER_NAME=\"$computetarget_name\""
