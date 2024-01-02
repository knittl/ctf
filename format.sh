#shellcheck shell=sh
# no shebang, must be sourced

# a bunch of functions which should simplify working with ANSI SGR escape sequences
# it's not efficient, but simple to use

_e() { printf '%s\n' "$*"; }
echo() { _e "$@"; } # redefine echo to be sane

sgr_color() { _e "$bgfg$1"; }
sgr_attr() { # sgr_attr attribute
	case "$1" in
		[0-9]) _e "$1" ;;
		reset) _e 0 ;;
		strong|b|bold|bright|intense) _e 1 ;;
		faint|dim) _e 2 ;;
		em|i|italic) _e 3 ;;
		u|underline) _e 4 ;;
		blink) _e 5 ;;
		blink-rapid,rapid) _e 6 ;;
		reverse) _e 7 ;;
		conceal|hide) _e 8 ;;
		s|strike|crossed-out) _e 9 ;;
		not) printf 2 ;; # 2X
		fg|foreground) bgfg=3 ;;
		bg|background) bgfg=4 ;;
		black)   sgr_color 0 ;;
		red)     sgr_color 1 ;;
		green)   sgr_color 2 ;;
		yellow)  sgr_color 3 ;;
		blue)    sgr_color 4 ;;
		magenta) sgr_color 5 ;;
		cyan)    sgr_color 6 ;;
		white)   sgr_color 7 ;;
		default) sgr_color 9 ;;
	esac
}

sgr() { printf '\033[%sm' "$(sgr_attr fg; for attr; do sgr_attr "$attr"; done | paste -sd ';')"; }
spread() ( set -f && IFS=', ' && "$1" ${2+$2} )

sgr_reset="$(sgr reset)" # cache frequently-used, constant value
fmt() { # fmt attr1,attr2,attrN text...
	attrs="$1"; shift
	printf "%s%s%s\n" "$(spread sgr "$attrs")" "$*" "$sgr_reset"
}

bold() { fmt bold "$@"; }
underlined() { fmt underline "$@"; }
