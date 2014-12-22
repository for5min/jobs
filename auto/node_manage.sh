#!/bin/bash

#node_manage.sh add scaleworks04 ping check_ping

NAGIOS_PATH=/usr/local/nagios
NAGIOS_CFG_DIR=/usr/local/nagios/etc
NRPE_CFG=$NAGIOS_CFG_DIR/nrpe.cfg
NODE_PATH=/usr/local/nagios/etc/objects/nodes/

if [ -z $2 ] ;then 
  echo "I don't know which node I need to modify"
else 
  node=$2
fi

NODE=${node}.cfg

function file() {
  cd $NODE_PATH
  if [ ! -e $NODE ]; then 
  echo "Sorry, Your node is not existing"
  fi
}

desc=$3
new_command=$4



function add() {
  echo " define service { " >> $NODE
  echo "  use                    generic-service" >> $NODE
  echo "  host_name              ${node}          " >> $NODE
  echo "  service_description    ${desc}          " >> $NODE
  echo "  check_command          check_nrpe!${new_command}" >> $NODE
  echo " }" >> $NODE
}


function remove() {
  LINE=`sed -n -e "/check_nrpe\!${new_command}/=" $NODE`
  BL=$(($LINE-4))
  AL=$(($LINE+1))
  sed -i -e "${BL},${AL}d" $NODE
}





case $1 in
   -h|help)
     echo "Usage:"
     echo "node_manage.sh add scaleworks04 ping check_ping"
     echo "node_manage.sh rm"
     ;;
   add|ADD|-a)
      file
      add
   ;;
   rm|RM|-r)
      file
      remove
   ;;
   *)
     echo "I didn't know what to do"
   ;;
esac
