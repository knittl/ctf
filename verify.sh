#!/bin/sh
. ./verify_lib.sh

# extracts the student id to lookup pepper, then verifies each submitted/found token
COURSE="$1"
peppers="$2"
[ "$#" -eq 2 ] && [ -f "$peppers" ] && [ -r "$peppers" ] || {
	err "Usage: $0 COURSE PEPPERSFILE"
	return 1
}

_load_pepper() {
	parse_token <<-TOKEN
	$token
	TOKEN
	setup_verify "$student" < "$peppers" 2>/dev/null
}

verify_tokens '' _load_pepper
