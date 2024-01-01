#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task
(
	dirname="$(rand_mkdir)"
	touch_ago() {
		ago="$1"
		touch -d "$1 years ago $1 month ago $1 week ago $1 day ago" "$2"
	}

	cd "$dirname"
	current_token | while parse_token; do
		year="$(random_int 10 20)"

		touch_ago 1 "$course"
		touch_ago 2 '{'
		touch_ago 3 "$exercise"
		touch_ago 4 ":$student:"
		printf '%s:%s' "$nonce" "$mac" | fold -w3 | {
			ago=6
			while read c; do
				touch_ago "$ago" "$c"
				ago="$((ago+1))"
			done
			touch_ago "$ago" '}'
		}
	done
	task "Token is all files in directory '$dirname', sorted by modification date"
)

# token in target of softlink
next_task
filename="$(uniq_filename)"
ln -s "$(current_token)" "$filename"
task "Token is target of symbolic link '$filename'"
