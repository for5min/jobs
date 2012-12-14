#!/bin/bash
function suse()
{
basename="/proj/www/puppet/"
confname="/etc/puppet/"
BIT=`getconf LONG_BIT`
VER=`grep ^SUSE /etc/SuSE-release | awk '{print $5}'`
PATCH=`grep ^PATC /etc/SuSE-release | awk '{print $3}'`
OS=$VER$PATCH$BIT
#install ruby,facter and rubyy
tar -xvf /proj/www/puppet-2.7.14.tar.gz -C /tmp > /dev/null 2>&1
filename="/tmp/puppet-2.7.14"
rpm -qa | grep ruby && rpm -qa | grep facter
if [[ "$?" -eq 0 ]];then
        cd $filename
        #./install.rb --full --bindir=/usr/bin --sbindir=/usr/sbin/
	./install.rb --full --bindir=/opt/eis_cm/bin --sbindir=/opt/eis_cm/sbin/
	cp $basename/puppet.conf $confname
	chown root:root $confname/puppet.conf
	#rm -rf $filename
else
	  case $OS in
	     11164) cd $basename/11164
		 rpm -ivh ruby-1.8.7.p72-5.24.2.x86_64.rpm facter-1.5.2-1.20.x86_64.rpm > /dev/null 2>&1
	         ;;
	    11264) cd $basename/11164
	         rpm -ivh ruby-1.8.7.p72-5.24.2.x86_64.rpm facter-1.5.2-1.20.x86_64.rpm > /dev/null 2>&1
		 ;;
	     10232) cd $basename/10232
	         rpm -ivh ruby-1.8.4-17.12.i586.rpm facter-1.5.1-7.1.i586.rpm > /dev/null 2>&1
	         ;;
             10264) cd $basename/10264
	         rpm -ivh ruby-1.8.4-2.1.x86_64.rpm facter-1.5.7-2.1.x86_64.rpm > /dev/null 2>&1
		 ;;
             10364) cd  $basename/10364
	         rpm -ivh ruby-1.8.4-2.1.x86_64.rpm facter-1.5.7-2.1.x86_64.rpm > /dev/null 2>&1
		 ;;
             10332) cd $basename/10332
	         rpm -ivh ruby-1.8.4-2.1.i586.rpm facter-1.5.7-2.1.i586.rpm > /dev/null 2>&1
		 ;;
      	*)    echo "Could not determine OS, exiting." ; exit 1 ;;
	      esac
    cd $filename
    #./install.rb --full --bindir=/usr/bin --sbindir=/usr/sbin/
    ./install.rb --full --bindir=/opt/eis_cm/bin --sbindir=/opt/eis_cm/sbin/
    cp $basename/puppet.conf $confname
    chown root:root $confname/puppet.conf
    #rm -rf $filename
fi
}
function suse_puppet()
{
	rpm -qa | grep puppet
	if [[ "$?" -eq 0 ]];then
		zypper remove -y puppet
                suse
	else
		suse
	fi
}
function rh_puppet()
{
        rpm -qa | grep puppet
        if [[ "$?" -eq 0 ]];then
	   yum remove -y puppet
           rh
       else
          rh
       fi
}
function rh()
{
basename="/proj/www/puppet/"
confname="/etc/puppet/"
BIT=`getconf LONG_BIT`
OS=`awk '{print $7}' /etc/redhat-release`
#install ruby,facter and rubyy
tar -xvf /proj/www/puppet-2.7.14.tar.gz -C /tmp > /dev/null 2>&1
filename="/tmp/puppet-2.7.14"
#rpm -qa | grep ruby && rpm -qa | grep ruby-libs && rpm -qa | grep facter
if [ "$OS" == "5" ];then
       cd $basename/54
      rpm -ivh ruby-libs-1.8.5-5.el5_3.7.x86_64.rpm ruby-1.8.5-5.el5_3.7.x86_64.rpm facter-1.5.7-2.1.x86_64.rpm > /dev/null 2>&1
      cd $filename
      ./install.rb --full --bindir=/opt/eis_cm/bin --sbindir=/opt/eis_cm/sbin/
       cp $basename/puppet.conf $confname
       chown root:root $confname/puppet.conf
      #rm -rf $filename
      else
      cd $basename/60
     rpm -ivh compat-readline5-5.2-17.1.el6.x86_64.rpm ruby-1.8.7.299-4.el6.x86_64.rpm ruby-libs-1.8.7.299-4.el6.x86_64.rpm facter-1.5.7-2.1.x86_64.rpm > /dev/null 2>&1
      cd $filename
     ./install.rb --full --bindir=/opt/eis_cm/bin --sbindir=/opt/eis_cm/sbin/
     cp $basename/puppet.conf $confname
     chown root:root $confname/puppet.conf
     #rm -rf $filename
fi
}

result="/proj/www/puppet/result"
hostname=`hostname`
if [ -f "/etc/SuSE-release" ];then
suse_puppet
touch $result/$hostname
elif [ -f "/etc/redhat-release" ];then
rh_puppet
touch $result/$hostname
#else if [ `uname -s` == "SunOS" ];
#then
else
	echo "Unable to detect OS"
	exit 1
#fi
fi
