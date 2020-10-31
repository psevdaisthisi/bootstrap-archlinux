#!/usr/bin/env sh

partition="$1"
periodsec="$2"
fmt="$3"

while :
do
	info=$(df | grep "$partition")
	used_spc="$(echo "$info" | awk '{printf "scale=1; %s / 1024 / 1024\n", $3}' | bc | awk '{printf "%sGiB", $1}')"
	used_perc="$(echo "$info" | awk '{printf "%s", $5}')"

	[ "$fmt" = "full" ] && echo "$used_spc ($used_perc)"
	[ "$fmt" = "space" ] && echo "$used_spc"
	[ "$fmt" = "percentage" ] && echo "$used_perc"

	sleep $2
done
