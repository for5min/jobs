#####################################
###  Lei Tu 2013-01-09            ###
#To fix login proble automaticly ####
###testing###
#!/bin/bash
function init_root(){
     echo -e "Welcome on board! Can't login LTS?(Y/N)"
     read answer
     case $answer in
	     Y|y|yes|YES|Yes) echo -e "You are typing yes!"
	                      ./root.sh
	     ;;
	     N|n|no|NO|No) echo -e "You are having no problem with it."
	                   exit 1
	     ;;
	     *) echo -n "You are typing nothing!Bye"
	        exit 1
	     ;;
      esac
}
function init_user(){
     echo -e "Welcome on board! Can't login LTS?(Y/N)"
     read answer
     case $answer in
                  Y|y|yes|YES|Yes) echo -e "You are typing yes!"
		                   ./user.sh
		   ;;
		  N|n|no|NO|No) echo -e "You are having no problem with it."
		   exit 1
		  ;;
		  *) echo -n "You are typing nothing!Bye"
		  exit 1
		  ;;
		  esac
	}

if  [ $USER != root ]; then
        init_user 
else
	init_root
fi
