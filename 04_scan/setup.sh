#!/bin/bash
######################################
# Scan soft symbolic link for storage
###################################################################
# 2012-05-28  Cecil.Han - Edit for the first time
# 2012-05-30  Cecil.han - Add pre-check to avoid duplicate running
###################################################################

###############################
# Judge OS Type before running
###############################
if [ "$(uname)" == "SunOS" ]; then
    exit 1
fi

####################
# Define paramters
####################
LOCK_FOLDER="/tmp/scanlock"
PID=$$
LOCK_FILE="$LOCK_FOLDER/$PID"
FILTER_FILE="./filter_list"
TMP_FILE="/tmp/tmp_filelist"
OUTPUT_FILE="/tmp/scan_out"
MOUNT_STATUS_FILE="/tmp/tmp_mount"
RESULT_FOLDER="/var/hubcron/results/scan_storage"
BASE_RESULT_NAME="$(hostname).scan"
RESULT_FILE="$RESULT_FOLDER/$BASE_RESULT_NAME"
MY_PARA_TMP=$(for i in $(cat $FILTER_FILE);do echo "-path" $i -o;done)
MY_PARA=$(echo ${MY_PARA_TMP%%-o});

#################################################################
# Check lock file and make sure we don't have any "find" process
#################################################################
mkdir -p $LOCK_FOLDER
pgrep "find" &>/dev/null && exit 1
[ $(ls -A $LOCK_FOLDER) ] && exit 1 || touch $LOCK_FILE

######################
# Check result folder
######################
if [ ! -d $RESULT_FOLDER ]; then
    mkdir $RESULT_FOLDER
fi

########################################
# Find the link file which point to nfs
########################################
find / -type d -a \( $MY_PARA \) -prune -o \( -type l -a ! -fstype nfs \) -print | xargs \
stat -f -c "Filename:%n:Type:%T" 2>/dev/null | grep "Type:nfs" | awk -F':' '{print $2}' > $TMP_FILE

#############################
# Clean and init output file
#############################
echo "#############################" > $OUTPUT_FILE
hostname >> $OUTPUT_FILE
date >> $OUTPUT_FILE
echo "#############################" >> $OUTPUT_FILE
echo >> $OUTPUT_FILE

###########################
# Get current mount status
###########################
mount | grep "type nfs" > $MOUNT_STATUS_FILE

#######################
# Get the output file
#######################
for i in $(cat $TMP_FILE)
do
    echo -n "Link file:$i" >> $OUTPUT_FILE
    SF="$(readlink -f $i)"
    echo "  Source file:$SF" >> $OUTPUT_FILE
    grep "$(echo "$SF" | awk -F'/' '{print "/"$2"/"$3}') " $MOUNT_STATUS_FILE >> $OUTPUT_FILE
    echo >> $OUTPUT_FILE
done

##########################
# Filter to final result
##########################
grep -v "proj" $OUTPUT_FILE | grep -v "^$" > $RESULT_FILE

#######################
# Remove the lock file
#######################
rm -f $LOCK_FILE

######
# END
######
