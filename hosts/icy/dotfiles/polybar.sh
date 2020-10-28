if [ "$(xrandr | grep 'DisplayPort-0 connected')" ]; then
	polybar internal &> "$HOME/.local/share/polybar/internal.log" &
	polybar external &> "$HOME/.local/share/polybar/external.log" &
else
	polybar solo &> "$HOME/.local/share/polybar/solo.log" &
fi
