#!/bin/bash
if [ $# != 1 ];then
  echo "Please specific the aboslute path of the file"
  exit 1
fi

if [ ! -f $1 ];then
  echo "Your file is not exsiting"
  exit 1
fi

LINE=`awk 'END{print NR}' $1`

for ((i=1; i<=$LINE; i++))
do
  export HOST=`awk -v a=$i 'NR==a {print $1}' $1`
  export CNAME=`awk -v a=$i 'NR==a {print $2}' $1`
  #  echo "aaa $HOST -t $CNAME"
  /usr/local/bin/infoblox-record-add -t cname -n $HOST -v $CNAME
done
