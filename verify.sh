#!/bin/sh
. "${0%/*}/verify_lib.sh"

# extracts the student id to look up pepper, then verifies each submitted/found token
peppersfile="$1"
[ "$#" -gt 0 ] && [ -f "$peppersfile" ] && [ -r "$peppersfile" ] || {
	err "Usage: $0 PEPPERSFILE"
	return 1
}

_load_pepper() {
	# cannot use pipe as it would create a subshell
	parse_token <<-TOKEN
	$token
	TOKEN
	setup_verify "$student" "$peppersfile" 2>/dev/null
}

verify() {
	COURSES="$(grep -v '^#' "$peppersfile" | cut -f1 | sort -u | join_lines '|')"
	verify_tokens '' _load_pepper;
}

shift
if test "$#" -gt 0
then printf '%s\n' "$@" | verify
else verify
fi
