#!/bin/bash
#count users' number and activity
#2013-02-22 eleituu


MONTH=`date -d last-month +%Y-%m`
DES=/tmp/logs
LOGDIR=/local/home/gerrit2/review_sh/logs
HTTPDES=$DES/http
SSHDES=$DES/ssh

function http_count()
{
if [ -d $HTTPDES ];then
cp $LOGDIR/httpd_log.$MONTH*.gz $HTTPDES
else
mkdir -p $DES/http
cp $LOGDIR/httpd_log.$MONTH*.gz $HTTPDES
fi

cd $HTTPDES;gunzip *

awk '{print $3,$4}' httpd_log* | sort -u | sed -e '/127.0.0.1/d' -e '/-/d' -e 's/\[//g' > httpd_log_timestamp.txt
awk '{print $3}' httpd_log* | sort -u | sed -e '/127.0.0.1/d' -e '/-/d' -e 's/\[//g' > httpd_log.txt

}

function sshd_count()
{
if [ -d $SSHDES ];then
cp $LOGDIR/sshd_log.$MONTH*.gz $SSHDES
else
mkdir -p $DES/ssh
cp $LOGDIR/sshd_log.$MONTH*.gz $SSHDES
fi

cd $SSHDES;gunzip *
awk '/FROM/' sshd_log* | awk '{print $1,$5}' | sort -u | sed 's/\[//g' > sshd_log.txt

}

function main()
{
if [ -d $DES ]; then
http_count
sshd_count
else
mkdir -p $DES
http_count
sshd_count
fi

echo "Reports as attachments for your reference." |mutt -a "/tmp/logs/http/httpd_log.txt" -a "/tmp/logs/http/httpd_log_time
stamp.txt" -a "/tmp/logs/ssh/sshd_log.txt" -s "Gerrit User Monthly Report" alex.tu@ericsson.com

}

main