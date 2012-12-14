#!/bin/bash

UNAME=`uname -s`
if [ -f /etc/SuSE-release ] ; then dist=suse ; fi
if [ -f /etc/redhat-release ] ; then dist=redhat ; fi
if [ $UNAME == "SunOS" ] ; then 
 dist=sun
 PATH=/usr/ucb:$PATH
fi

if [ `whoami` != "root" ]; then
  echo "ERROR: Script should be run as root"
  exit 1
fi

if [ "$dist" == "suse" ] ; then crontabfile=/var/spool/cron/tabs/root ; fi
if [ "$dist" == "redhat" ] ; then crontabfile=/var/spool/cron/root ; fi
if [ "$dist" == "sun" ] ; then crontabfile=/var/spool/cron/crontabs/root ; fi

cronentry="00 01 * * * [ -x /afs/sunrise.ericsson.se/afsadm/migration/migrate2DNS.sh ] && /afs/sunrise.ericsson.se/afsadm/migration/migrate2DNS.sh -l /proj/hpadmin/daniel"

echo "$cronentry" >> $crontabfile
