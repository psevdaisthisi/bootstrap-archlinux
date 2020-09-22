#!/usr/bin/env sh

partition=$1

while :
do
	info=$(df | grep "$partition")
	echo \
		$(echo "$info" | awk '{printf "scale=1; %s / 1024 / 1024\n", $3}' | bc | awk '{printf "%sGiB", $1}') \
		$(echo "$info" | awk '{printf "(%s)", $5}')
	# echo $(echo "$info" | awk '{printf "(%s)", $5}')
	sleep $2
done
