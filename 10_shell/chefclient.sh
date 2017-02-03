#!/bin/bash
# script.sh <SAS> --service <rpsp service> --role <chef role name> --name <node name> --environment <env name>

# By default we assume you are running with centos/ehel 7
CHEF_VERSION="12.18.31"
CHEF_MIN_VERSION="12.18.31-1"
CHEF_SERVER_HOSTNAME=""
CHEF_SERVER_IP=`host ${CHEF_SERVER_HOSTNAME} | awk '{print $4}'`
CHEF_SERVER_URL="https://${CHEF_SERVER_HOSTNAME}/organizations/myorg"

# blob storage
STORAGE_ACCOUNT=""
STORAGE_CONTAINER=""
STORAGE_SUFFIX="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${STORAGE_CONTAINER}/chef/"

function usage {
   echo "Usage:"
   echo "    script.sh <SAS> --service < service> --role <chef role name> --name <node name> --environment <env name>"
   exit 1
}

if [[ -z $1 ]];then
   echo "Please input your sastoken"
   usage
else
   SASTOKEN=$1
fi

while [[ $# -gt 1 ]]
do
key="$2"

case $key in
    -s|--service)
    SERVICE="$3"
    shift # past argument
    ;;
    -r|--role)
    ROLE="$3"
    shift # past argument
    ;;
    -n|--name)
    NAME="$3"
    shift # past argument
    ;;
    -e|--environment)
    ENVIRONMENT="$3"
    shift
    ;;
    *)
    usage
    exit 1
    ;;
esac
shift # past argument or value
done
echo ""
echo "Confirm your inputs"
echo "===================="
echo ""
echo SASTOKEN         = "${TOKEN}"
echo SERVICE          = "${SERVICE}"
echo ROLE             = "${ROLE}"
echo NODENAME         = "${NODE_NAME}"
echo ENVIRONMENT      = "${ENVIRONMENT}"

if [[ -z ${SERVICE} ]] || [[ -z ${ROLE} ]] || [[ -z ${NAME} ]] || [[ -z ${ENVIRONMENT} ]];then
    echo "one of the environment is empty"
    usage
fi


##install chefdk
function install_chefclient{

    yum update -y

    cd /tmp
    wget https://packages.chef.io/files/stable/chef/${CHEF_VERSION}/el/7/chef-${CHEF_MIN_VERSION}.el7.x86_64.rpm
    rpm -Uvh chef-${CHEF_MIN_VERSION}.el7.x86_64.rpm

    /bin/ping -c1 -W1 -q ${CHEF_SERVER_IP} &>/dev/null
    PING_STATUS=$( echo $? )
    if [[ ${PING_STATUS} == 0 ]] ; then
      echo "${CHEF_SERVER_IP} ${CHEF_SERVER_HOSTNAME}" >> /etc/hosts
    else
      echo "${CHEF_SERVER_HOSTNAME} is dead"
    fi
}

function fetch_compones{
  #If chef had been installed
  if [[ ! -d "/etc/chef" ]];then
    echo "Create Chef"
    mkdir -p /etc/chef
  if

  cd /etc/chef
  #fetch rpsp-validator.key
  wget -k "${STORAGE_SUFFIX}myorg-validator.pem${SASTOKEN}" -O myorg-validator.pem
  chown root:root myorg-validator.pem
  chmod 400 myorg-validator.pem

  if [[ ! -d "/etc/chef/trusted_certs" ]];then
    echo "Create Chef trusted_certs"
    mkdir -p /etc/chef/trusted_certs
  if
  
  cd /etc/chef/trusted_certs
  #fetch trusted_certs
  wget -k "${STORAGE_SUFFIX}chef_cert.crt${SASTOKEN}" -O chef_cert.crt
  chown root:root chef_cert.crt
  chmod 444 chef_cert.crt

  wget -k "${STORAGE_SUFFIX}Private_Root_CA.crt${SASTOKEN}" -O Private_Root_CA.crt
  chown root:root Private_Root_CA.crt
  chmod 444 Private_Root_CA.crt

  cd /etc/pki/tls/certs
  wget -k "${STORAGE_SUFFIX}myorg.pem${SASTOKEN}" -O myorg.pem
  chown root:root myorg.pem
  chmod 444 myorg.pem


}

function config_chef{

  if [[ ! -f "/etc/chef/myorg-validator.pem" ]];then
    echo "missing validation pem"
    fetch_compones
  if

#Write node.json
  cat <<EOF>/etc/chef/node.json
  {
     "run_list": ["${ROLE}"]
  }
EOF

#write client.rb
  cat <<EOF>/etc/chef/client.rb
  {
    node_name   "${NODE_NAME}"
    environment "${ENVIRONMENT}"
    log_level   :info,
    chef_server_url  "${CHEF_SERVER_URL}"
    validation_key   "/etc/chef/myorg-validator.pem"
    validation_client_name "myorg-validator"
    local_key_generation true
    ssl_verify_mode         :verify_peer
    ssl_ca_file             "myorg.pem",
    ssl_ca_path             "/etc/pki/tls/certs"
    log_location '/var/log/chef/client.log'
   }
EOF

  if [[ ! -d "/etc/chef/ohai" ]];then
    echo "Create Chef trusted_certs"
    mkdir -p /etc/chef/ohai/hints
  if
  cat <<EOF>/etc/chef/ohai/hints/azure.json
  {

  }
EOF
}

function run_chefclient {
  /usr/bin/chef-client -j /etc/chef/node.json -L /var/log/chef-first-run.log
  RUN_STATUS=$( echo $? )
    if [[ ${RUN_STATUS} == 0 ]] ; then
      echo "Chef running finished, please check the log"
    else
      echo "Something is wrong"
    fi
}

#Run the whole functions
install_chefclient
fetch_compones
config_chef
run_chefclient

