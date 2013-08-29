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

awk '{print $3,$4}' httpd_log* | sort -u | sed -e '/127.0.0.1/d' -e '/-/d' -e 's/\[//g' > ht
tpd_log_timestamp.txt
awk '{print $3}' httpd_log* | sort -u | sed -e '/127.0.0.1/d' -e '/-/d' -e 's/\[//g' > httpd
_log.txt

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
awk '/FROM/' sshd_log* | awk '{print $1,$5}' | sort -u | sed 's/\[//g' > sshd_log_timestamp.
txt
awk '/FROM/' sshd_log* | awk '{print $5}' | sort -u | sed 's/\[//g' > sshd_log.txt

}

function main()
{
if [ -d $DES ]; then
http_count
sshd_count
cat /tmp/logs/http/httpd_log.txt /tmp/logs/ssh/sshd_log.txt | sort -u > /tmp/logs/users.txt

else
mkdir -p $DES
http_count
sshd_count
cat /tmp/logs/http/httpd_log.txt /tmp/logs/ssh/sshd_log.txt | sort -u > /tmp/logs/users.txt
fi

echo "Reports as attachments for your reference." |mutt -a "/tmp/logs/users.txt" -a "/tmp/lo
gs/http/httpd_log.txt" -a "/tmp/logs/http/httpd_log_timestamp.txt" -a "/tmp/logs/ssh/sshd_lo
g.txt" -a "/tmp/logs/ssh/sshd_log_timestamp.txt" -s "Gerrit User Monthly Report" alex.tu@eri
csson.com

rm -rf $DES
}

main
