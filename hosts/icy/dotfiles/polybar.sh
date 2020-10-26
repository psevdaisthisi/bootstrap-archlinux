if [ "$(xrandr | grep 'DisplayPort-0 connected')" ]; then
	polybar internal &> "$HOME/.local/share/polybar/external.log" &
	polybar external &> "$HOME/.local/share/polybar/external.log" &
else
	polybar main &> "$HOME/.local/share/polybar/main.log" &
fi
