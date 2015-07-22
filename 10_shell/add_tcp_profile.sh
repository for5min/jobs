#!/bin/bash
#Add configue LB vserver
#Author: atu
#Before you are running the script, make sure your public key are add into LB /nsconfig/ssh/authorized_keys

usage() {
       echo "Usage: "
       echo "   -i input Load Balanace IP address"
       echo "   -c input Client number"
       echo "   -v input Client VIP address"
       echo "   -h print this page"
       echo "Option:"
       echo "   -u input running user name, the default is nsroot"
       echo "   -p input port number, the default is 443"
       echo "   -n input tcp profle name, the default is nstcp_ltp_learn"
       exit 1
}

USERNAME=nsroot
PORT=443
PROFILENAME=nstcp_ltp_learn

while getopts ':u:i:c:v:p:n:h:' opt; do
  case ${opt} in
    u) USERNAME=$OPTARG ;;
    i) LBIP=$OPTARG ;;
    c) CLIENTID=$OPTARG ;;
    v) VIP=$OPTARG ;;
    p) PORT=$OPTARG ;;
    n) PROFLIENAME=$OPTARG ;;
    h) usage ;;
    [?]) echo "Wrong option"
         echo "Run $0 -h for more details"
         exit 1;;
  esac
done

shift $((OPTIND-1))

COMMAND10="add ns tcpProfile ${PROFILENAME} -WS ENABLED -SACK ENABLED -WSVal 4 -mss 0 -maxBurst 10 -initialCwnd 6 -oooQSize 200 -maxPktPerMss 0 -pktPerRetx 2 -minRTO 200 -slowStartIncr 3 -bufferSize 600000 -synCookie ENABLED -KAprobeUpdateLastactivity ENABLED -flavor Westwood -dynamicReceiveBuffering ENABLED -KA DISABLED -KAconnIdleTime 900 -KAmaxProbes 3 -KAprobeInterval 75"

COMMAND9="add ns tcpProfile ${PROFILENAME} -WS ENABLED -SACK ENABLED -WSVal 4 -mss 0 -maxBurst 10 -initialCwnd 6 -oooQSize 200 -maxPktPerMss 0 -pktPerRetx 2 -minRTO 200 -slowStartIncr 3 -bufferSize 600000"

ns10 () {
  ssh ${USERNAME}@${LBIP} "show ns tcpProfile" | grep "${PROFILENAME}"
  if [ $? = 0 ];then
    echo "Your profile is exsiting"
    exit 1
  else
    ssh ${USERNAME}@${LBIP} "${COMMAND10}"
  fi
}

ns9() {
  ssh ${USERNAME}@${LBIP} "show ns tcpProfile" | grep "${PROFILENAME}"
  if [ $? = 0 ];then
    echo "Your profile already exsiting"
    exit 1
  else
    ssh ${USERNAME}@${LBIP} "${COMMAND9}"
  fi
}

add() {
  ssh ${USERNAME}@${LBIP} "set lb vserver ${CLIENTID}_vip_${VIP}:${PORT} -tcpProfileName ${PROFILENAME}"
  ssh ${USERNAME}@${LBIP} "save config"
}

if [ -z ${LBIP} ] || [ -z ${CLIENTID} ] || [ -z ${VIP} ];then
  usage
fi

echo "Start Citrix NetScaler configuration...."
ssh ${USERNAME}@$LBIP "show version" | grep "NS10.1"
if [ $? = 0 ];then
  ns10
else
  ns9
fi
  add
exit 0
