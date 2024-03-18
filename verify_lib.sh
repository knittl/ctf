#shellcheck shell=sh
# no shebang, must be sourced

. ./lib.sh

parse_token() { IFS='{:}' read -r course exercise student nonce mac _; }

setup_verify() {
	# cannot use pipe as it would create a subshell
	while read -r course student pepper name; do
		test "$student" = "$1" || continue
		export STUDENT="$1"
		export COURSE="$course"
		export TOKEN_PEPPER="$pepper"
		echo "$COURSE/$STUDENT $TOKEN_PEPPER" >&2
		break
	done
}

verify_token() {
	token="$1"
	pepper="${2:-$TOKEN_PEPPER}"
	echo "$token" | while parse_token; do
		expected="$(token "$exercise" "$course" "$student" "$pepper" "$nonce")"
		test "$token" = "$expected"
	done
}

extract_tokens() {
	test -t 0 && info '^D (CTRL-D) to submit'
	# TODO line buffered output
	grep -o "$COURSE{[^}]*}"
}

# TODO strict mode verification? i.e. exactly one flag per line
verify_tokens() {
	pepper="${1:-$TOKEN_PEPPER}"
	_setup_verify="$2"
	bad=
	extract_tokens | {
		while IFS='' read -r token; do
			token="$(echo "$token" | tr -d ' ')" # TODO translate before loop?
			test "$token" || continue
			${_setup_verify:+"$_setup_verify"}
			if verify_token "$token" "$pepper"; then
				echo "$(fmt green ✔) $token${name+ from $name}"
			else
				echo "$(fmt red ✘) $token"
				bad=1
			fi
		done
		test -z "$bad"
	}
}

