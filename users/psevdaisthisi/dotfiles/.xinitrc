# vim:ft=sh

[ ! -d "$HOME/.cache/wal" ] && wal --theme base16-chalk
xrdb -merge "$HOME/.Xresources"
xrdb -merge "$HOME/.cache/wal/colors.Xresources"
xsetroot -cursor_name left_ptr

#/usr/bin/env /usr/bin/bash --login -c "config-hids"
exec bspwm -c "$XDG_CONFIG_HOME/bspwm/bspwmrc"
