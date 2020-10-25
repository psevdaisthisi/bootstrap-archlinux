#!/usr/bin/env sh

thermal_zone=$(\
	for i in /sys/class/hwmon/hwmon*; \
		do echo "$i $(<$i/name)"; done | \
		grep "$1" | \
		awk '{print $1'} \
)

while :
do
	echo $((`cat $thermal_zone/temp1_input` / 1000))
	sleep $2
done
