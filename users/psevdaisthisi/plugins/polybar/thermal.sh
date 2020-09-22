#!/usr/bin/env sh

thermal_zone=$(\
	for i in /sys/class/thermal/thermal_zone*; \
		do echo "$i $(<$i/type)"; done | \
	grep "$1" | \
	awk '{print $1'} \
)

while :
do
	echo $((`cat $thermal_zone/temp` / 1000))
	sleep $2
done
