#!/usr/bin/env bash

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Wait until the process has been terminated
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

export BOL_ICON="$(echo -e "\uf0e7 ")"
export CAL_ICON="$(echo -e "\uf073")"
export CPU_ICON="$(echo -e "\uf5dc ")"
export ETH_ICON="$(echo -e "\uf796 ")"
export EXG_ICON="$(echo -e "\uf362 ")"
export FRQ_ICON="$(echo -e "\uf83e ")"
export HDD_ICON="$(echo -e "\uf0a0 ")"
export HGL_ICON="$(echo -e "\uf252 ")"
export KBD_ICON="$(echo -e "\uf11c ")"
export MEM_ICON="$(echo -e "\uf538 ")"
export MUT_ICON="$(echo -e "\uf6a9")"
export PWR_ICON="$(echo -e "\uf011")"
export TMP_ICON="$(echo -e "\uf2c8 ")"
export WIF_ICON="$(echo -e "\uf1eb")"
export BAT_ICON="$(echo -e "\uf241 ")"
export PCO_ICON="$(echo -e "\uf1e6 ")"
export BFL_ICON="$(echo -e "\uf240 ")"
export BKL_ICON="$(echo -e "\uf0eb ")"

[ ! -p "$HOME/.local/share/polybar/polytimer-fifo" ] &&
	mkfifo "$HOME/.local/share/polybar/polytimer-fifo"

source "$script_path/start.host.sh"
