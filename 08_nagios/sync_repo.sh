#!/bin/bash
if [ -f /var/lock/subsys/rsync_repo_updates ]; then
    echo "Updates via rsync already running."
    exit 0
fi
if [ -d /repo/CentOS/6.5 ] ; then
     touch /var/lock/subsys/rsync_updates
     rsync  -avSHP --delete --exclude "updates/x86_64/Packages/kdebase*" --exclude "updates/x86_64/Packages/java*" --exclude "os/x86_64/images" --exclude "updates/x86_64/Packages/firefox*" --exclude "extras" --exclude "os/i386" --exclude "updates/i386" --exclude "SCL" --exclude "centosplus" --exclude "cr" --exclude "contrib" --exclude "fasttrack" --exclude "xen4" --exclude "local*" --exclude "isos" centos.mirror.facebook.net::6.5/ /repo/CentOS/6.5/
     /bin/rm -f /var/lock/subsys/rsync_updates
else
    echo "Target directory /repo/CentOS/6.5 not present."
fi
