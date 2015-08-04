#!/bin/bash
#Add configue LB vserver
#Author: atu
#Before you are running the script, make sure your public key are add into LB /nsconfig/ssh/authorized_keys
#Usage ./add_tcp_profile.sh -i 10.112.254.10 -c 513100 -v 103.225.232.52 -p 443 -n nstcp_ltp_learn

#usage func
usage() {
       echo "Usage: "
       echo "Mandatory:"
       echo "   -i input Load Balanace IP address"
       echo "   -f import Client Number and VIP from file, once it's enabled, -c and -v won't work"
       echo "   -c input Client number"
       echo "   -v input Client VIP address"
       echo "   -h print this page"
       echo "Option:"
       echo "   -u input running user name, the default is nsroot"
       echo "   -p input port number, the default is 443"
       echo "   -n input tcp profle name, the default is nstcp_ltp_learn"
       exit 1
}

##Valiables
onflag=false
USERNAME=nsroot
PORT=443
PROFILENAME=nstcp_ltp_learn

COMMAND10="add ns tcpProfile ${PROFILENAME} -WS ENABLED -SACK ENABLED -WSVal 4 -mss 0 -maxBurst 10 -initialCwnd 6 -oooQSize 200 -maxPktPerMss 0 -pktPerRetx 2 -minRTO 200 -slowStartIncr 3 -bufferSize 600000 -synCookie ENABLED -KAprobeUpdateLastactivity ENABLED -flavor Westwood -dynamicReceiveBuffering ENABLED -KA DISABLED -KAconnIdleTime 900 -KAmaxProbes 3 -KAprobeInterval 75"

COMMAND9="add ns tcpProfile ${PROFILENAME} -WS ENABLED -SACK ENABLED -WSVal 4 -mss 0 -maxBurst 10 -initialCwnd 6 -oooQSize 200 -maxPktPerMss 0 -pktPerRetx 2 -minRTO 200 -slowStartIncr 3 -bufferSize 600000"

#check ip validation
checkip() {
  echo $1 |grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$" > /dev/null
  if [ $? != 0 ];    then
    echo "Your input is not valid, please try again"
    exit 1
  else
    a=`echo $1 | awk -F. '{print $1}'`
    b=`echo $1 | awk -F. '{print $2}'`
    c=`echo $1 | awk -F. '{print $3}'`
    d=`echo $1 | awk -F. '{print $4}'`
    #echo $a $b $c $d

    for loop in $a $b $c $d
    do
      if [ $loop -ge 255 ] || [ $loop -le 0 ]; then
        return 2
      fi
    done
  fi
}

#available for NS10
ns10() {
  ssh ${USERNAME}@${LBIP} "show ns tcpProfile" | grep "${PROFILENAME}"
  if [ $? = 0 ];then
    echo "Your profile is exsiting"
  else
    ssh ${USERNAME}@${LBIP} "${COMMAND10}"
  fi
}

#available for NS9
ns9() {
  ssh ${USERNAME}@${LBIP} "show ns tcpProfile" | grep "${PROFILENAME}"
  if [ $? = 0 ];then
    echo "Your profile already exsiting"
  else
    ssh ${USERNAME}@${LBIP} "${COMMAND9}"
  fi
}

addfromentrytolb() {
  #echo "addfromentrytolb"
  ssh ${USERNAME}@${LBIP} "set lb vserver ${CLIENTID}_vip_${VIP}:${PORT} -tcpProfileName ${PROFILENAME}"
  ssh ${USERNAME}@${LBIP} "save config"
}

addfromfiletolb() {
  if [ ! -e ${FILENAME} ];then
    echo "Your file is not existing"
    exit 1
  fi

  LINE=`awk 'END{print NR}' ${FILENAME}`

  for ((i=1; i<=${LINE}; i++))
  do
    CLIENTID=`awk -v a=${i} 'NR==a {print $1}' ${FILENAME}`
    VIP=`awk -v a=${i} 'NR==a {print $2}' ${FILENAME}`
    #echo "addfromfiletolb"
    ssh ${USERNAME}@${LBIP} "set lb vserver ${CLIENTID}_vip_${VIP}:${PORT} -tcpProfileName ${PROFILENAME}"
  done

    ssh ${USERNAME}@${LBIP} "save config"
}


excute() {
  ssh ${USERNAME}@${LBIP} "show version" | grep "NS10.1"
  if [ $? = 0 ];then
    ns10
  else
    ns9
  fi
}

main() {
checkip ${LBIP}
echo "Start Citrix NetScaler configuration...."

if ! ${onflag};then
  excute
  addfromentrytolb
else
  excute
  addfromfiletolb
fi

}


while getopts ':u:i:c:v:p:n:f:h:' opt; do
  case ${opt} in
    u) USERNAME=$OPTARG ;;
    i) LBIP=$OPTARG ;;
    c) CLIENTID=$OPTARG ;;
    v) VIP=$OPTARG ;;
    p) PORT=$OPTARG ;;
    n) PROFLIENAME=$OPTARG ;;
    f) onflag=true;FILENAME=$OPTARG;;
    h) usage ;;
    [?]) echo "Wrong option"
         echo "Run $0 -h for more details"
         exit 1;;
  esac
done

shift $((OPTIND-1))
#if $LBIP not define,return function usage
if [ -z ${LBIP} ] ;then
  usage
fi
main
