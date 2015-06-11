#!/bin/bash

#./nrpe_manage.sh add command_alias "command details" 
#./nrpe_manage.sh rm command_alias
#./nrpe_manage.sh mod command_alias "command details"
#./nrpe_manage.sh list

NRPE_CFG_PATH=/usr/local/nagios/etc/

COMMAND_ALIAS=$2
COMMAND_DETAILS_All=$*
#echo $COMMAND_DETAILS_All
COMMAND_DETAILS=`echo $COMMAND_DETAILS_All | awk '{$1=$2=""}sub("^"FS"*","")'`
#echo $COMMAND_DETAILS

function list() {
  cd $NRPE_CFG_PATH
  awk '/\[*_*\]/' nrpe.cfg  | grep -v '#' | sed -e 's/command\[//g' -e 's/\]\=//g' | awk -F/ '{print $1}'
}

function list_all() {
  cd $NRPE_CFG_PATH
  awk '/\[*_*\]/' nrpe.cfg  | grep -v '#' | sed -e 's/command\[//g' -e 's/\]\=/ => /g'
}

function add() {
 cd $NRPE_CFG_PATH
 echo "command[${COMMAND_ALIAS}]=${COMMAND_DETAILS}" >> nrpe.cfg
}

function remove() {
 cd $NRPE_CFG_PATH
 #awk '/${COMMAND_ALIAS}/ { print NR,$0}' nrpe.cfg
 #sed -n -e "/$COMMAND_ALIAS/p" nrpe.cfg
 grep -n "${COMMAND_ALIAS}" nrpe.cfg

 echo "which line you want to delete ?"
 read line
 sed -i.bak -e "${line}d" nrpe.cfg
}

case $1 in
  help|HELP|-h)
    echo "nrpe_manage.sh add command_alias command details"
    echo "nrpe_manage.sh rm command_alias"
    echo "nrpe_manage.sh mod command_alias command details"
    echo "nrpe_manage.sh list"
    ;;
  list|LIST|-l)
     list_all
  ;;
  add|ADD|-a)
    add
  ;;
  rm|RM|-r)
    remove
  ;;
  *)
   echo "I don't know what to do"
  ;;
esac
