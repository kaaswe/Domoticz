#!/bin/bash

########################################################################
## 2016
## info@janlarsson.net
## This is a dirty script to compensate for bad readings from my lightsensor that sometimes misses out, or get interferances.


# Logging, enable only ONE
# LightLog=/var/log/light.log
LightLog=/dev/null 2>&1 &

# ligth sensor ID
Sensor=/mnt/1wire/20.9D2C10000000/volt.B

# endless loop
while [ 1 ]; do

# read 5 values into the array arr with 2 seconds apart, check for error readings
let i=0
while [ $i -lt 5 ]
do
	myvalue=`cat $Sensor|sed -e s/" "//g|awk '{$1=$1 * 1000;printf "%.0f", $1}'`
	if [ $myvalue -le "40" ]; then
		# if no reading, decrease counter to read the same array post again.
		i=$[$i-1]
		echo "wrong value" $myvalue >> $LightLog
	else
		# else value ok
		arr[$i]=$myvalue
	fi
        echo "value "$i": " ${arr[$i]} >> $LightLog
	sleep 2
	i=$[$i+1]
done

# sort values from arr into arr2
arr2=($(
for el in  "${arr[@]}"
do
	echo "$el"
done | sort
))

# skip lowest and highest reading and use the 3 in the middle, sum them up and split to get average value
let sum=(${arr2[1]}+${arr2[2]}+${arr2[3]})/3
echo "Sum: " $sum >> $LightLog

# update domoticz dummy device Lux with the average value
curl -s "http://1.2.3.4:8080/json.htm?type=command&param=udevice&idx=8&nvalue=0&svalue=$sum" >/dev/null 2>&1 &

# sleep a while but longer at night
if [ $sum -le "70" ]; then
	# if it's dark then don't check so often.
	sleep 360
	else
	# else check every minute
	sleep 60
fi
done


