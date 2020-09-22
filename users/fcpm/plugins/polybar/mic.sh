#!/usr/bin/env sh

while :
do
	allmuted="yes"

	for is_muted in $(pactl list sources | grep Mute | awk '{print $2}')
	do
		[ $is_muted = "no" ] && allmuted="no" && break
	done

	[ $allmuted = "yes" ] && echo -e "\uf131" || echo -e "\uf130"

	sleep $1
done
