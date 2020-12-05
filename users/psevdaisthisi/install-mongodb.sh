curl --connect-timeout 13 --retry 5 --retry-delay 2 \
	-L 'https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian10-x86_64-100.2.1.tgz' \
	-o /tmp/mongodb-tools.tgz &&
curl --connect-timeout 13 --retry 5 --retry-delay 2 \
	-L 'https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-debian10-4.4.2.tgz' \
	-o /tmp/mongodb.tgz &&
mkdir -p /tmp/mongodb /tmp/mongodb-tools &&
tar fvxz mongodb.tgz -C /tmp/mongodb/ --wildcards  '*/bin/*' --strip-components=1 &&
tar fvxz mongodb-tools.tgz -C /tmp/mongodb-tools/ --wildcards  '*/bin/*' --strip-components=1 &&
mv /tmp/mongodb/bin/mongo* "$HOME/.local/bin/" &&
mv /tmp/mongodb-tools/bin/mongo* "$HOME/.local/bin/" &&
rm -rf /tmp/mongodb*
