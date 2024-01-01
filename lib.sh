#shellcheck shell=sh
# no shebang, must be sourced

# helper funcs
say() { printf '%s\n' "$*"; }
join_lines() { paste -sd "${1:-}"; }
ansi() {
			case "$1" in
				reset) say 0 ;;
				bold|intense) say 1 ;;
				faint|dim) say 2 ;;
				italic) say 3 ;;
				underline) say 4 ;;
				blink) say 5 ;;
				rapid) say 6 ;;
				reverse) say 7 ;;
				strike|crossed-out) say 9 ;;
				not) printf 2 ;; # 2X
				fg) bgfg=3 ;;
				bg) bgfg=4 ;;
				black) say "${bgfg}0" ;;
				red) say "${bgfg}1" ;;
				green) say "${bgfg}2" ;;
				yellow) say "${bgfg}3" ;;
				blue) say "${bgfg}4" ;;
				magenta) say "${bgfg}5" ;;
				cyan) say "${bgfg}6" ;;
				white) say "${bgfg}7" ;;
			esac
}
fmt() { printf '[%sm' "$(ansi fg; for arg; do ansi "$arg"; done | join_lines ';')"; }
formatted() { format="$1"; shift; printf "%s%s%s\n" "$(fmt "$format")" "$*" "$color_reset"; }
color_reset="$(fmt reset)"
color_red="$(fmt bold red)"
color_green="$(fmt bold green)"
color_yellow="$(fmt bold yellow)"
color_blue="$(fmt bold blue)"
color_bold="$(fmt bold)"
color_underline="$(fmt underline)"
bold() { colored "$color_bold" "$@"; }
underlined() { colored "$color_underline" "$@"; }
colored() { color="$1"; shift; printf "$color%s$color_reset\n" "$*"; }
err() { colored "$color_red" "⚠️ $*"; } >&2
if test "$DBG"
then dbg() { printf "${color_yellow}DBG${color_reset}: %s\n" "$*"; } >&2
else dbg() { :; }
fi
info() { colored "$color_green" "ℹ️  $*"; } >&2
next_task() {
	current_task="$((current_task+1))";
	level="$(level)";
}
level() { printf '%s-%s%s\n' "$current_level" "$current_task" "${current_subtask:+.$current_subtask}"; }
task() { printf "📝 %s%s\n\n" "${current_task:+[$(level)] }" "$*"; } >&2
# TODO extra format for question text?

leetify() {
	tr 
		'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' \
		'@bcd3f9h!jk7mn0pqr5+uvwxy24B(D3F6H1JK7MN0PQR$TUVWXY2'
}

to_lower() { tr '[:upper:]' '[:lower:]'; }
to_upper() { tr '[:lower:]' '[:upper:]'; }

input() {
	if test "${1+set}"
	then printf '%s\n' "$@"
	else cat
	fi
}

repeat() {
	count="$1"; shift
	for _ in $(seq "$count"); do "$@"; done
}

take() { dd bs=1 count="$1" 2>/dev/null; } # TODO use head -c"$1"?

init_level() {
	: "${current_level:?must be set}";
	current_task=0
	level="$(level)"
}
init_root() {
	root="${1?root dir missing}"
	test -d "$root" || mkdir -p "$root" || exit 1
	cd "$root" || exit 1
	root="$PWD" # get absolute path
}

# random helpers
random_device='/dev/urandom'

random_gen() { tr -cd "$1" < "$random_device"; }
random_alpha() { random_gen '[:alpha:]' | take "${1:-8}"; }
random_alnum() { random_gen '[:alnum:]' | take "${1:-8}"; }
random_digits() { random_gen '[:digit:]' | take "${1:-8}"; }
random_base32() { random_gen 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567' | take "${1:-8}"; }
random_name() { random_alnum "$@"; }
random_filename() { random_name "$(random_int "${1:-4}" "${2:-16}")"; }
random_perm() { echo "0$(random_int 0 7)$(random_int 0 7)$(random_int 0 7)"; }
random_seq() { seq "$(random_int "$1" "$2")"; }
pick_random() { shuf ${1+-e} -n1 "$@"; }
chance() { test "$(random_int 0 99)" -lt "${1:-50}"; }

random_int() {
	if test "$2"
	then shuf -n1 -i"$1-$2"
	else shuf -n1 -i"1-${1:-8}"
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
		for p in r w x; do pick_random "$p" ''; done
		test "$user" = o || echo ","
	done | join_lines
}

random_perm_sym() {
	for user in u g o; do
		for p in r w x; do pick_random "$p" '-'; done
	done | join_lines
}


# files
uniq_filename() {
	while filename="$("${1:-random_filename}")" && test -e "$filename"; do :; done
	printf '%s\n' "$filename"
}
rand_touch() {
	filename="${1:-$(uniq_filename)}"
	touch -- "$filename" && printf '%s\n' "$filename"
}
rand_mkdir() {
	filename="${1:-$(uniq_filename)}"
	mkdir -p -- "$filename" && printf '%s\n' "$filename"
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
_token() {
	format_data="$1"
	shift
	token_init "$@" || return 1
	mac="$(mac "$data:$pepper")"
	render_token  "$("$format_data" "$data")" "$mac"
}
_data() { printf '%s' "$1"; }
_data_placeholder() { _data "${1%:*}:%s"; }
token() { _token _data "$@"; }
token_format() {
	_token _data_placeholder "$1" "$3" "$4" "$5" "$2" # pin nonce
}
render_token() {
	printf '%s{%s:%s}\n' "$course" "$1" "$mac"
}

current_token() { token "$(level)"; }
current_fake_token() { fake_token "$(level)"; }

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
	extract_tokens | {
		while IFS='' read -r token; do
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
}

setup() {
	echo 'Running setup ...'
	printf 'Enter course [BIT]: '; read -r COURSE
	printf 'Enter student Sxxx: '; read -r STUDENT
	: "${COURSE:=BIT}"
	: "${STUDENT:?must be set. Call setup}"
	export COURSE
	export STUDENT
	TOKEN_PEPPER="$(random_alnum)"
	export TOKEN_PEPPER
	info "Token pepper: '$TOKEN_PEPPER'"
	echo 'Setup complete.'
}
