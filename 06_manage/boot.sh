############################
#startup LVD          ######
#2012.01.24 eleituui      ##
#!/bin/bash
PATH=/opt/xensource/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

function init(){
#echo "This script only used for LVD shutdown by mistake"
echo "what's the name of your LVD"
read name
echo "You will bootup LVD $name?(Y/N)"
read var
case $var in
    Y|y|yes|Yes|YES) boot;;
    N|n|no|No|NO) exit 0;;
    *) echo "Bee! Your choise is wroing"
    ;;
esac
}

function boot(){
xe vm-start name-label=$name
}

init
echo "The $name is booting up"

#list vm
#xe vm-list | awk -F: '{if($0 ~/(uuid|name)/)print $2}' | sed -e 's/^ //g' -e 'N;s/\n/ /' -e '/Control/d' > /tmp/vm