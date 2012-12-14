#!/bin/bash
if [ `uname -s` == "Linux" ];
then
	echo "23 23 * * *   root  test -x /var/hubcron/cron-daily && /var/hubcron/cron-daily >/dev/null 2>&1" >> /etc/crontab
else if [ `uname -s` == "SunOS" ];
then
		echo "23 23 * * * test -x /var/hubcron/cron-daily && /var/hubcron/cron-daily >/dev/null 2>&1" >> /var/spool/cron/crontabs/root
else
        echo "Unable to detect OS"
        exit 1
fi
fi
