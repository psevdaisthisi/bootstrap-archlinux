#!/usr/bin/env sh

while :
do
	all=$(cat /proc/cpuinfo | grep MHz | awk '{print $4}')
	sum=$(echo "$all" | paste -sd '+' - | bc)
	num=$(echo "$all" | wc -l)
	avg=$(echo "scale=2; $sum / $num / 1000" | bc)

	echo "${avg}GHz"
	sleep $1
done
