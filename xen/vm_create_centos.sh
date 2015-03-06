#!/bin/bash

#Define Displayname & Diskname
VML=Image_centos65

REPO=http://10.18.2.179/CentOS/6.5/os-min
KS=http://10.18.2.179/fedora/ks/C65.ks


#Support we are using local storage
SRUUID=`xe sr-list name-label="Local storage" --minimal`

#Get template uuid

TPUUID=`xe template-list name-label="CentOS 6 (64-bit)" --minimal`


#Use RHEL ENTERPRISE 6 64bit as template
VMUUID=`xe vm-install new-name-label=${VML} sr-uuid=${SRUUID} template=${TPUUID}`


#Set CPUs and Memory
create_vm() {
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
  xe vm-param-set other-config:install-repository="${REPO}" uuid=${VMUUID}
  xe vm-param-set PV-args="console=hvc0 utf8 nogpt noipv6 ks=${KS}" uuid=${VMUUID}

  #Change default VDI to 40GiB
  #VBDUUID=`xe vbd-list vm-name-label=${VML} --minimal`
  #VDIUUID=`xe vbd-param-get uuid=${VBDUUID} param-name=vdi-uuid --minimal`
  #xe vdi-resize uuid=${VDIUUID} disk-size=40GiB

  #We are not removing the data
  #xe vm-disk-remove vm=${VML}
  #ORIVBD=`xe vbd-list vm-name-label={VML} --minimal`

  #Add extra disk
  #xe vm-disk-add uuid=${VMUUID} sr-uuid=${SRUUID} device=2 disk-size=40GiB
  #VDBUUID=`xe vbd-list vm-uuid=${VMUUID} userdevice=0 params=uuid --minimal`
  #xe vbd-param-set bootable=true uuid=${VDBUUID}

  #Create relative network with eth0
  BRUUID=`xe network-list bridge=xenbr0 --minimal`
  xe vif-create vm-uuid=${VMUUID} network-uuid=${BRUUID} mac=random device=0

  #ADD cdrom as devices, then reject xs-tools. since it will be installed with ks
  xe vm-cd-add cd-name=xs-tools.iso device=1 vm=${VML}
  xe vm-cd-eject uuid=${VMUUID}

  #Start to install
  xe vm-start uuid=${VMUUID}
}

create_template() {
  #rename default VDI
  VBDUUID=`xe vbd-list vm-name-label=${VML} device=xvda --minimal`
  VDIUUID=`xe vbd-param-get uuid=${VBDUUID} param-name=vdi-uuid --minimal`
  xe vdi-param-set uuid=${VDIUUID} name-label=${VML} name-description="create by cli"

  while true
  do
    DOMAINID=`list_domains | grep ${VMUUID} | awk '{ print $1}'`
    CODE=`xenstore-read /local/domain/${DOMAINID}/attr/Customs/Kickstart`
    if [ "$CODE" == "0" ]; then
      SPUUID=`xe vm-snapshot name-label=${VML}  new-name-label=Image-${VML}_${DATE} new-name-description=
      Image-${VML}`
      xe snapshot-copy uuid=${SPUUID} new-name-label=Image-${VML}
      break
    fi
    echo "it's not finishing yet"
    sleep 300
  done
}

stop_template() {
  xe vm-shutdown force=true vm=${VML}
  xe vm-param-set uuid=${VDIUUID} name-label=${VML}-Live
}

create_vm
sleep 600
create_template
stop_template
