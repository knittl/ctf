#!/bin/sh

. ./lib.sh >/dev/null

if [ "$#" -lt 1 ]; then
	err "Usage: $0 COURSE [FILE]..."
	exit 1
fi

course="$1"; shift

cat "$@" | while read -r student name; do
	test "$student" || continue
	test "${student#'#'}" = "$student" || continue # skip comments
	student="$(input "$student" | to_lower)"
	printf '%s\t%s\t%s\t%s\n' "$course" "$student" "$(random_alnum)" "$name"
done
