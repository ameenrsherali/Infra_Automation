#!/usr/bin/env bash
# Created by Matthew Talbot & Ameen Riaz Sherali

# Inline Variables - see above
echo "Please enter Applications Name (6 Digits Max) eg, jetbrd";
read APP_CODE; # example "cust" 3 Digit Code
echo "Please enter Environment that the application is being deployed to (dev,qa,stg,prd)";
read ENVIRONMENT;
echo "Please enter Location that the application is being deployed to. ('eastus' would be the default value to enter).";
read LOCATION;
echo "Please enter Business Case Number (If it is not a new project use 'missing')";
read BC; # lowercase values "103985" 
echo "Please enter Cost Center Number (If it is not a new project use 'missing')";
read CC; # lowercase values "6008"
echo "Enter Project Manager Jetblue Email Address";
read PM; # lowercase values "jane.doe@jetblue.com"
echo "Enter Application Owner(Manager) Jetblue Email Address";
read APP_OWNER; # lowercase values "6008"


TEAM_EMAIL=ITPE_Azure_Support@jetblue.com; # Used for default permissions

echo ""  #New Line

#Echo entries accepted
echo "Application Name entered is '$APP_CODE'";
echo "Environment Being deployed to is '$ENVIRONMENT'";
echo "Zone of deployment is '$LOCATION'";
echo "Business Center of the application is '$BC'";
echo "Cost Center of the application is '$CC'";
echo "Project Manager Email is '$PM'";
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
        --tags "BC"="${BC}" "CC"="${CC}" "PM"="${PM}" "APP_OWNER"="${APP_OWNER}";
}

# Azure Functions
CREATE_RESOURCE_GRP; # Creates a Resource Group for the project