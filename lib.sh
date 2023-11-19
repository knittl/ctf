# no shebang, must be sourced

# helper funcs
color_reset='[0m'
color_red='[1;31m'
color_green='[1;32m'
color_yellow='[1;33m'
color_blue='[1;34m'
colored() { color="$1"; shift; printf "$color%s$color_reset\n" "$*"; }
err() { colored "$color_red" "⚠️ $*" >&2; }
dbg() { test "$DBG" && printf "${color_yellow}DBG${color_reset}: %s\n" "$*" >&2; }
info() { colored "$color_green" "ℹ️  $*" >&2; }
task() { colored "$color_blue" "📝 $*" >&2; }
# TODO extra format for question text?

leetify() {
	tr 
		'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' \
		'@bcd3f9h!jk7mn0pqr5+uvwxy24B(D3F6H1JK7MN0PQR$TUVWXY2'
}

to_lower() { tr '[:upper:]' '[:lower:]'; }
to_upper() { tr '[:lower:]' '[:upper:]'; }

join_lines() { paste -sd "${1:-}"; }

getinput() {
	# TODO getinput
	if test -t 0;
	then printf '%s' "$1"
	else cat
	fi
}

segment() {
	size="${2:-16}"
	delim="${3:--}"
	getinput "$1" |
		fold -w"$size" |
		join_lines "$delim"
}

take() { dd bs=1 count="$1" 2>/dev/null; } # TODO use head -c"$1"?

# random helpers
random_device='/dev/urandom'

random_gen() { tr -cd "$1" < "$random_device"; }
random_alpha() { random_gen '[:alpha:]' | take "${1:-8}"; }
random_alnum() { random_gen '[:alnum:]' | take "${1:-8}"; }
random_digits() { random_gen '[:digit:]' | take "${1:-8}"; }
random_name() { random_alnum "$@"; }
random_filename() { random_name "$(random_int "${1:-4}" "${2:-16}")"; }
random_perm() { echo "0$(random_int 0 7)$(random_int 0 7)$(random_int 0 7)"; }
random_seq() { seq "$(random_int "$1" "$2")"; }
pick_random() { shuf -n1 "$@"; }
chance() { test "$(random_int 0 99)" -lt "${1:-50}"; }

random_int() {
	if test "$2"
	then pick_random -i"$1-$2"
	else pick_random -i"1-${1:-8}"
	fi
	# case "$#" in
	# 	0) shuf -n1 -i1-8 ;;
	# 	1) shuf -n1 -i"1-$1" ;;
	# 	*) shuf -n1 -i"$1-$2" ;;
	# esac
}

random_perm_chmod() {
	for user in u g o; do
		echo "$user="
		for p in r w x; do pick_random -e "$p" ''; done
		test "$user" = o || echo ","
	done | join_lines
}


# files
uniq_filename() {
	while filename="$(random_filename)"; do test -e "$filename" || break; done
	printf '%s' "$filename"
}
rand_touch() {
	filename="${1:-$(uniq_filename)}"
	touch -- "$filename" && echo "$filename"
}
rand_mkdir() {
	filename="${1:-$(uniq_filename)}"
	mkdir -p -- "$filename" && echo "$filename"
}


# TODO token
token_init() {
	token_init_course "$@"
	token_init_mac "$@"

	if test -z "$course" || test -z "$student" || test -z "$exercise"; then
		err "token EXERCISE [COURSE STUDENT [PEPPER [NONCE]]]" >&2
		return 1
	fi

	if test -z "$pepper"; then
		err 'No pepper provided (run setup or export TOKEN_PEPPER)!'
	fi

	data="$exercise:$student:$nonce"
}
token_init_course() {
	exercise="${1}"            # e.g. 1-2
	course="${2:-$COURSE}"     # BIT
	student="${3:-$STUDENT}"   # matrikelnummer: Sxxxx...
}
token_init_mac() {
	pepper="${4:-$TOKEN_PEPPER}"      # TODO
	nonce="${5:-$(random_alnum)}"     # TODO
}
token() {
	token_init "$@" || return 1
	mac="$(mac "$data:$pepper")"
	printf '%s{%s:%s}\n' "$course" "$data" "$mac"
}

mac() {
	printf '%s' "$1" | sha256sum | xxd -r -p | base32 -w0 | take 8;
	# printf '%s' "$1" | sha256sum | take 8;
}

# fake_pepper='invalid' # export? # TODO randomize?
# dbg "Fake token pepper: $fake_pepper"
# fake_token() (TOKEN_PEPPER="$fake_pepper" token "$1") # run in subshell
fake_token() {
	token_init "$@" || return 1
	printf '%s{%s:%s}\n' "$course" "$data" "$(random_alnum 8)"
}


parse_token() { IFS='{:}' read -r course exercise student nonce mac _; }

verify_token() {
	token="$1"
	pepper="${2:-$TOKEN_PEPPER}"
	printf '%s\n' "$token" | while parse_token; do
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
	bad=
	extract_tokens | while IFS='' read -r token; do
		token="$(printf '%s' "$token" | tr -d ' ')" # TODO translate before loop?
		test "$token" || continue
		if verify_token "$token" "$pepper"; then
			echo "${color_green}✔${color_reset} $token"
		else
			echo "${color_red}✘${color_reset} $token"
			bad=1
		fi
	done
	test -z "$bad"
}

setup() {
	echo 'Running setup ...'
	read -p 'Enter course [BIT]: ' COURSE
	read -p 'Enter student Sxxx: ' STUDENT
	: "${COURSE:=BIT}"
	: "${STUDENT:?must be set. Call setup}"
	export COURSE
	export STUDENT
	export TOKEN_PEPPER="$(random_alnum)"
	info "Token pepper: '$TOKEN_PEPPER'"
	echo 'Setup complete.'
}
