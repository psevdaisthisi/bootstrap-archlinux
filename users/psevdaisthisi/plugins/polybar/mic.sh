#!/usr/bin/env sh

printstatus () {
	allmuted="true";

	echo "$1" | grep --silent "source" && {
		for ismuted in $(pactl list sources | grep Mute | awk '{print $2}'); do
			[ $ismuted = "no" ] && allmuted="false" && break
		done
		[ "$allmuted" = "true" ] && echo -e "\uf131" || echo -e "\uf130";
	}
}

printstatus "source"
pactl subscribe | {
	while read evt; do printstatus "$evt" ; done
}
