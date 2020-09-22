color_default="\033[0m"
color_red="\033[0;31m"
color_green="\033[0;32m"
color_orange="\033[0;33m"
color_blue="\033[0;36m"

function printinfo { echo -e "${color_blue}$1${color_default}"; }
function printsucc { echo -e "${color_green}$1${color_default}"; }
function printwarn { echo -e "${color_orange}$1${color_default}"; }
function printerr { echo -e "${color_red}$1${color_default}"; }

function yesno {
	while true; do
		read -p "$* [Y/n]: " answer
		case $answer in
			Y) true && return;;
			n) false || return;;
		esac
	done
}
