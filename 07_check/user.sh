######################################
###Lei Tu 2013-01-09              ####
###sub script of check.sh         ####
######################################
#!/bin/bash
#enter user password
export PATH=/usr/bin:/bin:/usr/sbin:$PATH

function check_passwd(){
       echo -e "##############################"
       ypcat passwd | grep $signum
       echo -e "##############################"
              if [[ "$?" -eq 0 ]];then
		 echo -e "Your Unix account is existing."
		 echo -e "Processing next....."
	      else
		 echo -e "BANG!"
		 echo -e "Your Unix account is not existing, please request it via GORDON"
		 exit 0
	      fi
	 }

function check_hubhome(){
       ypcat auto.homehub | grep $signum
       if [[ "$?" -eq 0 ]];then
	       echo -e "Your hub home directory is existing"
	       echo -e "Your currently Hub home usage as below"
	       echo -e "#####################################"
               df -h $HOME | grep %
	       echo -e "#####################################"
	       echo -e "Check your hub home's premission"
	       echo -e "#####################################"
	       ls -l /home | grep $USER
	       echo -e "#####################################"
	       echo -e "Please remain it as 711"
       else
	       echo -e "Please be patiented, your hub home is creating, please find support from Hub Support Team"
	       exit 0
       fi
       }
function check_idm(){
       /opt/quest/bin/vastool -u instcnshsv -k /proj/hpadmin/VAS/keys/instcnshsv_eapac.key attrs -u $signum | awk /cnshrndithub/ >/dev/null 2>&1
       if [[ "$?" -eq -0 ]];then
	       echo -e "Your IDM group is existing.."
	       echo -e "Processing next...."
       else
	       echo -e "BANG!BANG!"
	       echo -e "Your IDM group Rnd_access_cnsh does not exist, please request it by yourself"
	       exit 0
       fi
}
function remove_file(){
       echo -e "Still can't login?"
       echo -e "Go back to check with your home usage."
       echo -e "If reach to 100%, you can't login either."
       echo -e "In order to make your work safty, Please do house keeping by yourself!"
       }
function command(){
        if [ $USER = $signum ]; then
        check_passwd
	check_hubhome
	check_idm
        remove_file
        else
		echo "You are running with other username,make sure you are running your own"
		exit 0
	fi
 }
echo -e "Please enter your signum!"
read signum
echo -e "Your signum is $signum?(Y/N)"
read var
case $var in
	    Y|y|yes|YES|Yes) #echo "You are typing yes!"
	                     command
	   ;;
	    N|n|no|NO|No) echo "You are having no problem with it."
	   exit 1;;
   	*) echo "You are typing nothing!Bye"
         exit 1;;
	esac
