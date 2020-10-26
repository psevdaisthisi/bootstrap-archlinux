# vim:ft=sh

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

[ ! -d "$HOME/.cache/wal" ] && wal --theme base16-chalk
xrdb -merge "$HOME/.Xresources"
xrdb -merge "$HOME/.cache/wal/colors.Xresources"
xsetroot -cursor_name left_ptr

[ -f "$script_path/.xinitrc.host" ] &&
	source "$script_path/.xinitrc.host"

#/usr/bin/env /usr/bin/bash --login -c "config-hids"
exec bspwm -c "$XDG_CONFIG_HOME/bspwm/bspwmrc"
