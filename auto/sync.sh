#!/bin/bash
#sync.sh 192.168.X.X
whoami=`whoami`

RSA_FILE=/home/scaleworks/.ssh/id_rsa

HOST=$1
NAGIOS_CFG_DIR=/usr/local/nagios/etc



cd $NAGIOS_CFG_DIR
if [ $whoami == 'root' -o  $whoami == 'scaleworks' ]; then
    scp -i $RSA_FILE nrpe.cfg scaleworks@${HOST}:/tmp
    ssh -i $RSA_FILE scaleworks@${HOST} "sudo mv /tmp/nrpe.cfg ${NAGIOS_CFG_DIR} && sudo chown nagios:nagios ${NAGIOS_CFG_DIR}/nrpe.cfg
      "
    else
      echo "Please run as root or scaleworks"
     exit 1
    fi
fi
