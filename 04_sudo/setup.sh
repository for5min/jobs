#!/bin/bash
Date=`date +%Y%m%d`

#function backup()
#{
#cp /etc/opt/quest/sudo/sudoers{,_$Date} && cp /etc/sudoers{,_$Date}
#}
function rh()
{
grep "cnshrepo" /var/spool/cron/root > /dev/null 2>&1
if [[ "$?" -eq 0 ]];then
exit 0;
else
echo "10 * * * * [ -f /proj/cnshrepo/sudo/sudoers ] && cp -p /proj/cnshrepo/sudo/sudoers /etc/sudoers && cp -p /proj/cnshrepo/sudo/sudoers /etc/opt/quest/sudo/sudoers && chmod 0440 /etc/sudoers && chmod 0440 /etc/opt/quest/sudo/sudoers" >> /var/spool/cron/root
fi
}
function ss()
{
grep "cnshrepo" /var/spool/cron/tabs/root > /dev/null 2>&1
if [[ "$?" -eq 0 ]];then
exit 0;
else
       echo "10 * * * * [ -f /proj/cnshrepo/sudo/sudoers ] && cp -p /proj/cnshrepo/sudo/sudoers /etc/sudoers && cp -p /proj/cnshrepo/sudo/sudoers /etc/opt/quest/sudo/sudoers && chmod 0440 /etc/sudoers && chmod 0440 /etc/opt/quest/sudo/sudoers" >> /var/spool/cron/tabs/root
fi
}
function sol()
{
grep "cnshrepo" /var/spool/cron/crontabs/root > /dev/null 2>&1
if [[ "$?" -eq 0 ]];then
exit 0;
else
echo "10 * * * * [ -f /proj/cnshrepo/sudo/sudoers ] && cp -p /proj/cnshrepo/sudo/sudoers /etc/sudoers && cp -p /proj/cnshrepo/sudo/sudoers /etc/opt/quest/sudo/sudoers && chmod 0440 /etc/sudoers && chmod 0440 /etc/opt/quest/sudo/sudoers" >> /var/spool/cron/crontabs/root
fi
}
if [ -f "/etc/SuSE-release" ];
then
#        backup
	ss
elif [ -f "/etc/redhat-release" ];
then
#	backup
        rh
else if [ `uname -s` == "SunOS" ];
then
#        backup 
	sol
else
        echo "Unable to detect OS"
        exit 1
fi
fi
