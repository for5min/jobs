#!/bin/bash

#Define Displayname & Diskname
VML=fedora20


#Support we are using local storage
SRUUID=`xe sr-list name-label=Local\ storage --minimal`


#Use RHEL ENTERPRISE 6 64bit as template
VMUUID=`xe vm-install new-name-label=${VML} sr-uuid=${SRUUID} template=bb74a987-fe42-6889-fd94-aa4b3955da47`


#Set CPUs and Memory

xe vm-param-set VCPUs-max=1 uuid=${VMUUID}
xe vm-param-set VCPUs-at-startup=1 uuid=${VMUUID}
xe vm-param-set memory-dynamic-max=1GiB uuid=${VMUUID}
xe vm-param-set memory-static-max=1GiB uuid=${VMUUID}
xe vm-param-set memory-dynamic-min=1GiB uuid=${VMUUID}
xe vm-param-set memory-static-min=1GiB uuid=${VMUUID}

#Set HV or PV
xe vm-param-set HVM-boot-policy="" uuid=${VMUUID}
xe vm-param-set PV-bootloader="eliloader" uuid=${VMUUID}

#After setting PV, transfer install url and Kickstart
xe vm-param-set other-config:install-repository="http://10.18.2.179/fedora/20/os" uuid=${VMUUID}
xe vm-param-set PV-args="console=hvc0 utf8 nogpt noipv6 ks=http://10.18.2.179/fedora/ks/f20.ks" uuid=${VMUUID}

#Change default VDI to 40GiB
#VBDUUID=`xe vbd-list vm-name-label=${VML} --minimal`
#VDIUUID=`xe vbd-param-get uuid=${VBDUUID} param-name=vdi-uuid --minimal`
#xe vdi-resize uuid=${VDIUUID} disk-size=40GiB

#We are not removing the data
#xe vm-disk-remove vm=${VML}
#ORIVBD=`xe vbd-list vm-name-label={VML} --minimal`

#Add extra disk
#xe vm-disk-add uuid=${VMUUID} sr-uuid=${SRUUID} device=1 disk-size=40GiB
#VDBUUID=`xe vbd-list vm-uuid=${VMUUID} userdevice=0 params=uuid --minimal`
#xe vbd-param-set bootable=true uuid=${VDBUUID}

BRUUID=`xe network-list bridge=xenbr0 --minimal`
xe vif-create vm-uuid=${VMUUID} network-uuid=${BRUUID} mac=random device=0

#ADD cdrom

xe vm-cd-add cd-name=xs-tools.iso device=1 vm=${VML}
xe vm-cd-eject uuid=${VMUUID}

xe vm-start uuid=${VMUUID}
