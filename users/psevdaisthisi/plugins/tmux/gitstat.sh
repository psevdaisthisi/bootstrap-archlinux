#!/usr/bin/env bash

_dir=""
while [[ $# -gt 0 ]]
do
	case "$1" in
		-d|--dir)
			_dir="$2"
			shift
			shift
			;;
	esac
done

[ ! -d "$_dir" ] && _dir='.'

cd "$_dir" &> /dev/null
if [ $(git rev-parse --is-inside-work-tree 2> /dev/null) ]; then
	stat=$(git status --branch --short)
	branch=$(git branch | grep '^\*' | sed 's/\* //')
	num_staged=$(echo "$stat" | grep '^A\|^D\|^M\|^R' | wc -l)
	num_modified=$(echo "$stat" | grep '^.M' | wc -l)
	num_renamed=$(echo "$stat" | grep '^.R' | wc -l)
	num_deleted=$(echo "$stat" | grep '^.D' | wc -l)
	num_new=$(echo "$stat" | grep '^??' | wc -l)
	echo " @""$branch" "$num_staged"+ "$num_modified"m "$num_renamed"r "$num_deleted"d "$num_new""? "
fi
cd - &> /dev/null
