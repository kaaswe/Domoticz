# Domoticz
Home automation scripts for 1-wire and Domoticz

# 1 Lightsensor
Files: light_01.sh
This is a bash script for Raspberry and 1-wire with the analog lightning sensor based on DS2450S with TSL250R. This is a dirty script to compensate for bad or fluctuating values.

The script is started as a service and runs an endless loop, it will periodically read 5 values into an array of the lightning device and skip the high and low values to sum an average for the remaning three. The average value will update a dummy device in Domoticz by a json call.

The main reason for this is to make sure to always have a nice and smooth graph. When low values, ie dark outside, are detected the script will not poll as often as during day time.

# 2 Malware protection for NAS.
This is my way of protecting my NAS disks from rsync bad data from primary to secondary disk by simply check the number of changed files each day, this is described in detail in the NAS_Backup_Process.pdf.

Files:
rsync.sh - The backup script on my NAS that will check status and update status on Domoticz.
NAS_Backup_Process.pdf - Describes the process flow of the NAS Backup script
