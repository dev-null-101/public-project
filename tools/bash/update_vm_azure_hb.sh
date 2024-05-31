#!/usr/bin/bash
# Script to update the license to Azure Hybrid Benefits

# log & temp
backup_date=`date +%d%m%Y%H%M%S`
sub_log="./log/subscription_ahb_update.log"
rg_log="./log/resourcegroup_ahb_update.log"
vm_log="./log/virtualmachine_ahb_update.log"
tmp="./temp"

# Whitelist
rg_whitelist="./whitelist/rg_whitelist.txt"
vm_whitelist="./whitelist/vm_whitelist.txt"

function pre_check() {
  # Subscription and user account validation
  echo "INFO: Checking your Azure user id information..." \
    | sed -e "s/INFO:/"$'\e[32m'"&"$'\e[m'"/"

  # Check azure userid should be -ba
  userid=`az account show --query "[user.name]" -o tsv`
  ba="-ba"
  if [[ "$userid" != *"$ba"* ]]
  then
    echo "WARN: Please use your -ba account to run this script." \
      | sed -e "s/WARN:/"$'\e[33m'"&"$'\e[m'"/"
    exit 1
  fi

  # Get all subscriptions
  echo "INFO: Running query for all available subscriptions for your account..." \
    | sed -e "s/INFO:/"$'\e[32m'"&"$'\e[m'"/"
  az account subscription list --query "[].{Name:displayName}" -o tsv > $tmp/query_sub_list.txt 2>/dev/null
  if [ ! -z $subscription ]
  then
    grep -iw "^${subscription}" $tmp/query_sub_list.txt > /dev/null 2>&1
    if [ $? -ne 0 ]
    then
      echo "FAIL: $subscription subscription is invalid. Please check." \
        | sed -e "s/FAIL:/"$'\e[31m'"&"$'\e[m'"/" -e "s/$subscription/"$'\e[31m'"&"$'\e[m'"/"
      rm $tmp/query_sub_list.txt
      exit 1
    fi
  fi

  # Check the whitelist files
  ls -lrt $rg_whitelist $vm_whitelist > /dev/null 2>&1
  if [ $? -ne 0 ]
  then
    echo "WARN: Please check the existence of rg_whitelist.txt and vm_whitelist.txt."
    exit 1
  else
    # Remove \r if you are in windows or in vs code
    sed -i 's/\r//g' $rg_whitelist
    sed -i 's/\r//g' $vm_whitelist
  fi
}

# Where the actual VM update will happen
function vm_license_update() {
  if [ $os == 'Windows' ] && [ "$license_type" != "Windows_Server" ] && [ "$os_version" == "None" ]
  then
    echo "-> Updating $azure_vm_name..." \
      | sed -e "s/$azure_vm_name/"$'\e[34m'"&"$'\e[m'"/"
    echo "-> Running 'az vm update --subscription $subscription --resource-group $resource_group --name $azure_vm_name --set licenseType=Windows_Server'"
    ##az vm update --subscription $subscription --resource-group $resource_group --name $azure_vm_name --set licenseType=Windows_Server > /dev/null 2>&1
  elif [ "$license_type" == "Windows_Server" ]
  then
    echo "-> Skipping $azure_vm_name. License type is already in Azure Hybrid Benefit." \
      | sed -e "s/$azure_vm_name/"$'\e[32m'"&"$'\e[m'"/"
  else
    echo "-> Skipping $azure_vm_name. Unsupported Windows OS version." \
      | sed -e "s/$azure_vm_name/"$'\e[33m'"&"$'\e[m'"/"
  fi
}

###############################
# Update VMs per subscription #
###############################
function update_ahb_per_subscription {
  # Rename log if exists
  if [ -s $sub_log ]
  then
    mv $sub_log $sub_log.$backup_date
  fi

  # Lets remove \r if you are in windows or in vs code
  sed -i 's/\r//g' $subscriptions_file
  
  for subscription in `cat $subscriptions_file`
  do

   grep -iw $subscription $tmp/query_sub_list.txt > /dev/null 2>&1
   if [ $? -ne 0 ]
   then
    echo "WARN: Skipping $subscription subscription since it is invalid. Please check later." \
      | sed -e "s/WARN:/"$'\e[31m'"&"$'\e[m'"/" -e "s/$subscription/"$'\e[33m'"&"$'\e[m'"/"
    continue
   fi

   echo "INFO: Working on subscription: ${subscription}" \
    | sed -e "s/INFO:/"$'\e[32m'"&"$'\e[m'"/" -e "s/$subscription/"$'\e[32m'"&"$'\e[m'"/"

   # Should I include sub_whitelist?

   # Query all VM in the subscription
   echo "INFO: Running query for all VMs in ${subscription} subscription..." \
    | sed -e "s/INFO:/"$'\e[32m'"&"$'\e[m'"/"
   az vm list --subscription $subscription \
      --query "[].{Name:name,ResourceGroup:resourceGroup,OS:storageProfile.osDisk.osType,LicenseType:licenseType,OSVersion:storageProfile.imageReference.sku}" \
      -o tsv > $tmp/sub_vm_info.txt

   # Filter Windows OS only
   win_os_list=`awk -F' ' '$3 == "Windows" { print; }' $tmp/sub_vm_info.txt`

   # Loop all the VMs under the subscription
   (IFS=$'\n'
   for j in $win_os_list
   #for j in $(cat $win_os_list)
     do
       azure_vm_name=`echo $j | awk '{print $1}'`
       resource_group=`echo $j | awk '{print $2}'`
       os=`echo $j | awk '{print $3}'`
       license_type=`echo $j | awk '{print $4}'`
       os_version=`echo $j | awk '{print $5}'`

       # This will skip if the VM is in vm_whitelist.txt
       grep -i $azure_vm_name whitelist/vm_whitelist.txt > /dev/null 2>&1
       if [ $? -eq 0 ]
       then
         echo "-> Skipping $azure_vm_name. See vm_whitelist.txt file." \
          | sed -e "s/$azure_vm_name/"$'\e[33m'"&"$'\e[m'"/"
       continue
       fi

       # This will skip if the VM belong to a  resource group that in rg_whitelist.txt
       grep -i $resource_group whitelist/rg_whitelist.txt > /dev/null 2>&1
       if [ $? -eq 0 ]
       then
         echo "-> Skipping $azure_vm_name. See rg_whitelist.txt file." \
          | sed -e "s/$azure_vm_name/"$'\e[33m'"&"$'\e[m'"/"
         continue
       fi

       # Where the actual VM update will happen
       vm_license_update
      done)
  
    # Checkup vm_info.txt file before doing another loop
    rm $tmp/sub_vm_info.txt

  done #| tee -a $sub_log
}

#######################################
# Update all VMs of a resoource group #
#######################################
function update_ahb_per_resource_group {
  # Rename log if exists
  if [ -s $rg_log ]
  then
    mv $rg_log $rg_log.$backup_date
  fi

  # Query all VM in the subscription
  echo "INFO: Running query against ${resource_group} to capture VMs information's..." \
    | sed -e "s/INFO:/"$'\e[32m'"&"$'\e[m'"/" -e "s/$resource_group/"$'\e[32m'"&"$'\e[m'"/"
  az vm list --subscription $subscription \
    --query "[?resourceGroup=='$resource_group'].{Name:name,OS:storageProfile.osDisk.osType,LicenseType:licenseType,OSVersion:storageProfile.imageReference.sku}" -o tsv \
    > $tmp/rg_vm_info.txt

  # Filter Windows OS only
  win_os_list=`awk -F' ' '$2 == "Windows" { print; }' $tmp/rg_vm_info.txt`

  (IFS=$'\n'
    #for vm_in_rg in `cat rg_vm_info.txt`
    for vm_in_rg in $win_os_list
    do
      azure_vm_name=`echo $vm_in_rg | awk '{print $1}'`
      os=`echo $vm_in_rg | awk '{print $2}'`
      license_type=`echo $vm_in_rg | awk '{print $3}'`
      os_version=`echo $vm_in_rg | awk '{print $4}'`

      # This will skip if the VM is in vm_whitelist.txt
      grep -i $azure_vm_name whitelist/vm_whitelist.txt > /dev/null 2>&1
      if [ $? -eq 0 ]
      then
        echo "-> Skipping $azure_vm_name. See vm_whitelist.txt file." \
          | sed -e "s/$azure_vm_name/"$'\e[33m'"&"$'\e[m'"/"
        continue
      fi

      # This will skip if the VM belong to a  resource group that in rg_whitelist.txt
      grep -i $resource_group whitelist/rg_whitelist.txt > /dev/null 2>&1
      if [ $? -eq 0 ]
      then
        echo "-> Skipping $azure_vm_name. See rg_whitelist.txt file." \
          | sed -e "s/$azure_vm_name/"$'\e[33m'"&"$'\e[m'"/"
        continue
      fi

      # Where the actual VM update will happen
      vm_license_update

    done) # | tee -a $rg_log
    rm $tmp/rg_vm_info.txt
}

############################################
# Update all VMs listed in a file provided #
############################################
function update_ahb_per_virtualmachine {
  # Rename log if exists
  if [ -s $vm_log ]
  then
    mv $vm_log $vm_log.$backup_date
  fi

  # Lets remove \r if you are in windows or in vs code
  sed -i 's/\r//g' $vm_file

  echo "INFO: Running query in $subscription subscription to capture the VM informations..." \
    | sed -e "s/INFO:/"$'\e[32m'"&"$'\e[m'"/" -e "s/$subscription/"$'\e[32m'"&"$'\e[m'"/"
  az vm list --subscription $subscription \
    --query "[].{Name:name,ResourceGroup:resourceGroup,OS:storageProfile.osDisk.osType,LicenseType:licenseType,OSVersion:storageProfile.imageReference.sku}" -o tsv \
    > $tmp/vm_vm_info.txt

  for vm_input in `cat $vm_file`
  do

    # Check if the VM exist in the subscription
    grep -iw "$vm_input" $tmp/vm_vm_info.txt > /dev/null 2>&1
    if [ $? -ne 0 ]
    then
      echo "-> Skipping $vm_input. Invalid Azure vm name or its not within the $subscription subscription." \
        | sed -e "s/$vm_input/"$'\e[33m'"&"$'\e[m'"/"
      continue
    fi

    az_vm=`grep -iw $vm_input $tmp/vm_vm_info.txt`

    azure_vm_name=`echo $az_vm | awk '{print $1}'`
    resource_group=`echo $az_vm | awk '{print $2}'`
    os=`echo $az_vm | awk '{print $3}'`
    license_type=`echo $az_vm | awk '{print $4}'`
    os_version=`echo $az_vm | awk '{print $5}'`

    if [ "${os}" != "Windows" ]
    then
      echo "-> Skipping $azure_vm_name. None Windows OS." \
        | sed -e "s/$azure_vm_name/"$'\e[33m'"&"$'\e[m'"/"
      continue
    fi

    # This will skip if the VM is in vm_whitelist.txt
    grep -iw $azure_vm_name $vm_whitelist > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
      echo "-> Skipping $azure_vm_name. See vm_whitelist.txt file." \
        | sed -e "s/$azure_vm_name/"$'\e[33m'"&"$'\e[m'"/"
      continue
    fi
      
    # This will skip if the VM belong to a  resource group that in rg_whitelist.txt
    grep -iw $resource_group $rg_whitelist > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
      echo "-> Skipping $azure_vm_name. See rg_whitelist.txt file." \
        | sed -e "s/$azure_vm_name/"$'\e[33m'"&"$'\e[m'"/"
      continue
    fi

    # Where the actual VM update will happen
    vm_license_update

  done | tee -a $vm_log
  rm $tmp/vm_vm_info.txt
}

function usage {
        echo "Usage: ./$(basename $0) [-slrv]" 2>&1
        echo '   -l <subscriptions_list.txt>'
        echo '   -s <subscription> -r <resource group>'
        echo '   -s <subscription> -v <azure_vm_name_list.txt>'
        exit 1
}

if [[ ${#} -lt 2 ]]; then
    usage
fi

while getopts :l:s:r:v: options
do
  case $options in
    s) subscription=$OPTARG
        ;;
    l) subscriptions_file=$OPTARG
       if [ $subscriptions_file == "vm_whitelist.txt" ] || [ $subscriptions_file == "rg_whitelist.txt" ] || [ ! -s $subscriptions_file ]
       then
         echo "FAIL: Please check $subscriptions_file! Make sure it is not named vm_whitelist.txt/rg_whitelist.txt, exists and not empty." \
          | sed -e "s/FAIL/"$'\e[31m'"&"$'\e[m'"/" -e "s/$subscriptions_file/"$'\e[31m'"&"$'\e[m'"/"
         exit 1
       fi
       pre_check
       echo "INFO: Updating of license type to Azure Hybrid Benefit is in progress..." \
        | sed -e "s/INFO:/"$'\e[32m'"&"$'\e[m'"/" \
              -e "s/Azure Hybrid Benefit/"$'\e[32m'"&"$'\e[m'"/"
       update_ahb_per_subscription
       
       # Cleanup
       rm $tmp/query_sub_list.txt
       ;;
    r) resource_group=${OPTARG^^}
       pre_check
       echo "INFO: Updating of license type to Azure Hybrid Benefit is in progress..." \
        | sed -e "s/INFO:/"$'\e[32m'"&"$'\e[m'"/" \
              -e "s/Azure Hybrid Benefit/"$'\e[32m'"&"$'\e[m'"/"
       update_ahb_per_resource_group 

       # Cleanup
       rm $tmp/query_sub_list.txt
       ;;
    v) vm_file=$OPTARG
       if [ $vm_file == "vm_whitelist.txt" ] || [ $vm_file == "rg_whitelist.txt" ] || [ ! -s $vm_file ]
       then
        echo "FAIL: Please check $vm_file! Make sure it is not named vm_whitelist.txt/rg_whitelist.txt, exists and not empty." \
          | sed -e "s/FAIL/"$'\e[31m'"&"$'\e[m'"/" -e "s/$vm_file/"$'\e[31m'"&"$'\e[m'"/" 
       exit 1
       fi
       pre_check
       echo "INFO: Updating of license type to Azure Hybrid Benefit is in progress..." \
        | sed -e "s/INFO:/"$'\e[32m'"&"$'\e[m'"/" \
              -e "s/Azure Hybrid Benefit/"$'\e[32m'"&"$'\e[m'"/"
       update_ahb_per_virtualmachine
       
       # Cleanup
       rm $tmp/query_sub_list.txt
       ;;
    ?)
      echo "Invalid option: -${OPTARG}"
      echo
      usage
      ;;
  esac
done
