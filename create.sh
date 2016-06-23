#!/bin/bash
PERSONA=$1
CPU=$2
MEM=$3
CR=$4
PRDID=$5
MHHOSTNAME=$PERSONA.mhint
if [[ $PERSONA =~ .*db.* ]]
then
  /mnt/asp/utils/adam/flexgen/create-plain-flexgen-vm.rb -e va3 -n $PERSONA -d fg_sen01a_va3_vmdk_os -f Learn -c $CPU -m $MEM --asp-filer 10.6.84.1 --timezone America/Bogota --chef-runlist "role[rhel-base],role[learn-system],role[oracle-database]"
else 
  /mnt/asp/utils/adam/flexgen/create-plain-flexgen-vm.rb -e va3 -n $PERSONA -d fg_sen01a_va3_vmdk_os -f Learn -c $CPU -m $MEM --asp-filer 10.6.84.1 --timezone America/Bogota --chef-runlist "role[rhel-base], role[learn-system],role[learn-app-base],role[bbmh-java],role[bbmh-learn-newrelic-agent]"
fi

IP=`host ${PERSONA} |awk 'END{print $4}'`
/mnt/asp/utils/adam/flexgen/add-to-inventory --environment va3 --persona  $MHHOSTNAME --ticket $CR --cpu-count $CPU --memory-size $MEM --root-password N/A --ipaddr $IP --client-id 147231 --product-id $PRDID

echo "Post provisioning dont forget to run: /mnt/asp/utils/svaughan/fg/chef_addfs.pl --node $MHHOSTNAME --fs_dev $MOUNT_DEV --fs_mnt /home/oracle --fs_type oracle"
