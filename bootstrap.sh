# Examples
# long:   $ bash bootstrap.sh --host helium --user psevdaisthisi
# short:  $ bash bootstrap.sh -h helium -u psevdaisthisi

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${script_path}/misc.sh"

pushd "$script_path" > /dev/null

_host=""
_user=""
_stepping=""
while [[ $# -gt 0 ]]
do
	case "$1" in
		-h|--host)
			_host="$2"
			shift
			shift
			;;
		-s|--stepping)
			_stepping="--stepping"
			shift
			;;
		-u|--user)
			_user="$2"
			shift
			shift
			;;
		*)
			printwarn "Unknown option: '$1'. Will be ignored."
			shift
			;;
	esac
done

[ -z "$_host" ] && printerr "Missing mandatory '--host' option." && exit 1
[ -z "$_user" ] && printerr "Missing mandatory '--user' option." && exit 1

[ ! -f "hosts/${_host}/bootstrap.sh" ] && \
	printerr "Missing host bootstrap file at 'hosts/${_host}/bootstrap.sh'." && exit 1
[ ! -f "users/${_user}/bootstrap.sh" ] && \
	printerr "Missing user bootstrap file at 'users/${_user}/bootstrap.sh'." && exit 1

bash "hosts/${_host}/bootstrap.sh" --host ${_host} --user ${_user} ${_stepping}

printsucc "\n"
printsucc "The ${_host} host and the user account ${_user} were successfully configured!"
printsucc "Turn the power off the computer, remove the installation medium."

popd > /dev/null
