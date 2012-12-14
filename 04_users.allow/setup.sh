#!/bin/bash
host=`uname -n`
if [[ ${host:5:4} != "ux32" ]]; then
        echo "You are not target server"
	exit 1
else
   cp /proj/www/users.allow /etc/opt/quest/vas/users.allow
   chown root:root /etc/opt/quest/vas/users.allow
   /etc/init.d/vasd restart
   sleep 10
   /etc/init.d/vasd restart
fi
