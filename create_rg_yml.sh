#!/usr/bin/env bash
# Created by Matthew Talbot & Ameen Riaz Sherali

FILE=$1

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

TEAM_EMAIL=ITPE_Azure_Support@jetblue.com; # Used for default permissions

eval $(parse_yaml $FILE)

echo "############## Entered Variable Values are ################"  #New Line

#Echo entries accepted
echo "Application Name entered is '$APP_CODE'";
echo "Environment Being deployed to is '$ENVIRONMENT'";
echo "Zone of deployment is '$LOCATION'";
echo "Business Center of the application is '$BC'";
echo "Cost Center of the application is '$CC'";
echo "Project Manager Email is '$APP_PM'";
echo "Application Owner Email is '$APP_OWNER'";

# Set Subscriptionas per environment
if [ "${ENVIRONMENT}" = "stg" ] || [ "${ENVIRONMENT}" = "prd" ] || [ "${ENVIRONMENT}" = "uat" ];then
    AZURE_SUBSCRIPTION="Prod 2.0";
else 
    AZURE_SUBSCRIPTION="Non-Prod 2.0";
fi

echo "Subscription being deployed to based on choice of environment is '$AZURE_SUBSCRIPTION'"

echo""  #New Line

#Confirm if you wish to proceed
read -p "Do you wish to continue? Please type Y or N  : " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo""

#Defining Resource Group
RESOURCE_GRP="jb-rg-${APP_CODE}-${ENVIRONMENT}";

# Allowed IPS - Network Rules
ALLOWED_IPS=$(cat <<EOF
64.25.21.15
64.25.21.14
64.25.21.13
64.25.25.249
64.25.25.250
64.25.29.249
64.25.29.250
74.107.137.75
74.107.136.204
74.107.128.233
EOF
);



# Create Resource Group 
function CREATE_RESOURCE_GRP {
    CUR_DATE=$(date +%m-%d-20%y-%H-%M-%S);
    echo "NOW RUNNING: ${FUNCNAME[0]} ${CUR_DATE} ${ENVIRONMENT}";
    
    # Create Resource Group
    az group create \
        -n "${RESOURCE_GRP}" \
        --location "${LOCATION}" \
        --subscription "${AZURE_SUBSCRIPTION}" \
        --tags "BC"="${BC}" "CC"="${CC}" "PM"="${APP_PM}" "APP_OWNER"="${APP_OWNER}";
}

# Azure Functions
CREATE_RESOURCE_GRP; # Creates a Resource Group for the project