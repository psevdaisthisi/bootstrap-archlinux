#!/usr/bin/env sh

while :
do
	info=$(sudo iotop --accumulated --only --batch --iter=1 -qq | head -1)
	echo \
		$(echo "$info" | awk '{printf "R:%s%s", $5, $6}') \
		$(echo "$info" | awk '{printf "W:%s%s", $12, $13}')
	sleep $1
done
