# vim:ft=sh

if [ "$(xrandr | grep 'DisplayPort-0 connected')" ]; then

	if [ "$(grep 'Manufacturer: BNQ  Model: 802a'  $HOME/.local/share/xorg/Xorg.0.log)" ]; then
		xrandr --output eDP --primary --mode 1920x1080 --pos 0x1440 --rotate normal \
			--output DisplayPort-0 --mode 2560x1440 --pos 1426x0 --rotate normal \
			--output DisplayPort-1 --off \
			--output DisplayPort-2 --off

	elif [ "$(grep 'Manufacturer: LEN  Model: 61ae'  $HOME/.local/share/xorg/Xorg.0.log)" ]; then
		xrandr --output eDP --primary --mode 1920x1080 --pos 0x1124 --rotate normal \
			--output DisplayPort-0 --mode 2560x1440 --pos 1920x0 --rotate normal \
			--output DisplayPort-1 --off \
			--output DisplayPort-2 --off

	elif [ "$(grep 'Manufacturer: DEL  Model: d0ff'  $HOME/.local/share/xorg/Xorg.0.log)" ]; then
		xrandr --output eDP --primary --mode 1920x1080 --pos 320x1440 --rotate normal \
			--output DisplayPort-0 --mode 2560x1440 --pos 0x0 --rotate normal \
			--output DisplayPort-1 --off \
			--output DisplayPort-2 --off
	fi
fi
