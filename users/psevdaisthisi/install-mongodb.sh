script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

pushd "$script_path" > /dev/null

[ "$1" ] && prefix="/home/$1"
[ ! "$1" ] && prefix="$HOME"

curl --connect-timeout 13 --retry 5 --retry-delay 2 \
	-L 'https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian10-x86_64-100.2.1.tgz' \
	-o mongodb-tools.tgz &&
curl --connect-timeout 13 --retry 5 --retry-delay 2 \
	-L 'https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-debian10-4.4.2.tgz' \
	-o mongodb.tgz &&
mkdir -p mongodb mongodb-tools &&
tar fvxz mongodb.tgz -C mongodb/ --wildcards  '*/bin/*' --strip-components=1 &&
tar fvxz mongodb-tools.tgz -C mongodb-tools/ --wildcards  '*/bin/*' --strip-components=1 &&
mv mongodb/bin/mongo* "$prefix/.local/bin/" &&
mv mongodb-tools/bin/mongo* "$prefix/.local/bin/" &&
rm -rf mongodb*

popd > /dev/null
