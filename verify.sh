#!/bin/sh
. "${0%/*}/verify_lib.sh"

# extracts the student id to look up pepper, then verifies each submitted/found token
COURSE="$1"
peppersfile="$2"
[ "$#" -ge 2 ] && [ -f "$peppersfile" ] && [ -r "$peppersfile" ] || {
	err "Usage: $0 COURSE PEPPERSFILE"
	return 1
}

_load_pepper() {
	# cannot use pipe as it would create a subshell
	parse_token <<-TOKEN
	$token
	TOKEN
	setup_verify "$student" "$peppersfile" 2>/dev/null
}

verify() { verify_tokens '' _load_pepper; }

shift 2
if test "$#" -gt 0
then printf '%s\n' "$@" | verify
else verify
fi
