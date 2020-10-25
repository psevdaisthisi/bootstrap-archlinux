export NNN_BMS="0://;1:$VOL1;2:$VOL2;a:$AUR;c:$CODE;j:$JUNK;m:$MOUNT;s:$SYNC"

config-hids () {
	setxkbmap -option
	setxkbmap -layout pt
	setxkbmap -option "lv3:ralt_switch" \
	          -option "eurosign:e" \
	          -option "eurosign:5" \
	          -option "caps:escape" \
	          -option "terminate:ctrl_alt_bksp"
	xset r rate 190 70
}

set-backlight () {
	local device="amdgpu_bl0"
	local max="$(cat /sys/class/backlight/$device/max_brightness)"
	local curr="$(cat /sys/class/backlight/$device/brightness)"
	local diff=$(((($max + 21 - 1)) / 21))

	[ "$1" = "inc" ] && {
		local val=$(($curr +  $diff))
		[ $val -gt $max ] && val=$max
		echo $val > "/sys/class/backlight/$device/brightness"
	}

	[ "$1" = "dec" ] && {
		local val=$(($curr -  $diff))
		[ $val -lt 0 ] && val=0
		echo $val > "/sys/class/backlight/$device/brightness"
	}
}
