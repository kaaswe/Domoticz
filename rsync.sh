#!/bin/bash
#
# Jan Larsson 2017 info@janlarsson.net
#


my_files_counter=`find /NAS/folder/file -name \*.* -type f -mmin -1440 -not -path /NAS/folder/tmp/*.* | wc -l`

echo "Number of files changed in 24h: " $my_files_counter

# Update Domoticz dummy Alert and Dummy swith 'NAS backup' and prevent rsync until files on NAS are verified.
if [ $my_files_counter -ge 50 ] ; then
	nas_script=`curl -s "http://1.2.3.4:8080/json.htm?type=command&param=switchlight&idx=111&switchcmd=Off"`
	nas_alert=`curl -s "http://1.2.3.4:8080/json.htm?type=command&param=udevice&idx=112&nvalue=4&svalue=CRITICAL"`
	# echo "Domoticz update "
	exit 0
fi

# Let Domoticz rest and make sure the status has been updated before we read and check it.
echo "Let the program sleep 1 minute to give Domoticz a chance to catch up."
sleep 60

# Check if status has been set previously to Alert and not yet reseted, then bail out and don't do sync action.
my_alert_status=`curl -s "http://1.2.3.4:8080/json.htm?type=devices&rid=111"|  awk '/Data/ {print $3}' | sed 's/[^a-zA-Z]//g'`
echo "Domoticz Dummy NAS Backup swtich alert status: " $my_alert_status

if [ $my_alert_status == "On" ] ; then
	# Domoticz status is OK, carry on with rsync backup
	echo "Backup is started"
	rsync -av --exclude-from=/media/common/backups/excludes.txt --log-file=/media/common/backups/backup.txt /media /backup
	echo "rsync status: " $?
	# Update Domoticz Alert with green status
        if [ $? -eq 0 ] ; then
		 nas_alert=`curl -s "http://1.2.3.4:8080/json.htm?type=command&param=udevice&idx=112&nvalue=1&svalue=Backup_OK"`
	fi

	else
	echo "Backup prevented by Domoticz to run, check NAS file integrity and enable NAS_Backup_Script."
fi





