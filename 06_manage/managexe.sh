#######################
#Create LVM         ###
#2012.01.24 eleituui ##
#!/bin/bash
PATH=/opt/xensource/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

function init(){
echo -e "Checking the cluster enviroment now.....\n"
echo -e "====================================="
echo -e "VMname\t\tStatus"
xe vm-list | awk -F: '{if($0 ~/(name|power)/)print $2}' | sed -e 's/^ //g' -e 'N;s/\n/ /' -e '/Control/d' | tee /tmp/vmlist
echo -e "=====================================\n"
echo "Here are the status of machines.."
echo "Continue to (C)reate,(B)oot,(S)hutdown or (D)estroy an exsiting one?"
read cbd
case $cbd in
     C|c) create;;
     B|b) /root/boot.sh;;
     S|s) shutdown;;
     D|d) destroy;;
     *) echo "Bee! Your choise is wroing"
     ;;
esac
}

function create(){
echo "Hello, you will use this script to create new LVD."
echo "Who is booking this LVD?(signum)"
read signum
echo "what's new name of LVD?"
read vmname
echo "You will create LVD $vmname?(Y/N)"
read var
case $var in
    Y|y|yes|Yes|YES) process;;
    N|n|no|No|NO) exit 0;;
    *) echo "Bee! Your choise is wroing"
    ;;
esac
}

function process(){
grep $vmname /tmp/vmlist
if [[ $? -eq 0 ]];then
echo "Your LVD is exsiting..."
echo "Please boot it up"
/root/boot.sh
else
#the LVD template will change once we found things need to updated
VMUUID=`xe vm-install template=openSuseLVD.V1 new-name-label=$vmname-$signum`
xe vm-start uuid=$VMUUID
DISKUUID=`xe vm-disk-list uuid=$VMUUID | awk '/uuid/' | awk '{print $5}' | sed -n '2p'`
xe vdi-param-set name-label=$vmname uuid=$DISKUUID
xe vm-param-set name-description=$signum uuid=$VMUUID
echo "The vm is creating and startup.....Please be patient"
echo "Please login the machine to configure the IP,hostname and run the lastjoin under /etc/opt/quest/vas"
fi
}

function shutdown(){
echo "Which server you are going to shutdown"
read vmname
echo -e "$vmname is going to shutdown..."
xe vm-shutdown name-label=$vmname
exit 0
}

function destroy(){
echo "WARNING: YOU CAN NOT DESTORY ANY VM WITH RUNNING STATUS!!!"
echo "Which server you are going to destroy"
read vmname
echo -e "$vmname is going to gone..."
VMUUID=`xe vm-list name-label=$vmname | awk '/uuid/' |awk '{print $5}'`
DISKUUID=`xe vm-disk-list vm=$vmname | awk '/uuid/' | awk '{print $5}' | sed -n '2p'`
xe vm-destroy uuid=$VMUUID
xe vdi-destroy uuid=$DISKUUID
exit 0
}


init