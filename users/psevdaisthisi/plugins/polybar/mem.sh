#!/usr/bin/env sh

while :
do
	info=$(cat /proc/meminfo)
	total=$(echo "$info" | grep '^MemTotal:' | awk '{print $2}')
	free=$(echo "$info" | grep '^MemFree:' | awk '{print $2}')
	buffers=$(echo "$info" | grep '^Buffers:' | awk '{print $2}')
	cached=$(echo "$info" | grep '^Cached:' | awk '{print $2}')
	reclaimable=$(echo "$info" | grep '^SReclaimable:' | awk '{print $2}')
	used=$((total - free - buffers - cached - reclaimable))
	echo $(echo "scale=3; $used / 1024 / 1024" | bc)GiB
	sleep $1
done
