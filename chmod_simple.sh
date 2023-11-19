#!/bin/sh

. ./lib.sh

root="${1?root dir missing}"
num_files=8

test -d "$root" || mkdir -p "$root"

cd "$root"
root="$PWD" # get absolute path

rand_dir() { find "$1" -type d | pick_random; }
rand_cd() { cd "$(rand_dir "$root")"; }

## perms
filename="$(rand_touch)"
chmod "$(random_perm)" "$filename"
perms="$(stat -c'%A' "$filename")"
chmod "$(random_perm)" "$filename"

nonce="$(printf '%s' "$perms" | sha256sum | xxd -r -p | base64 | take 8)"
token_format="$(token_format 1-1 "$nonce")"

> /tmp/check_perm
chmod a+x /tmp/check_perm
cat >> /tmp/check_perm <<\SH
#!/bin/sh
usage() { echo "$0: File not found. Usage: $0 FILENAME" >&2; exit 1; }
[ -f "$1" ] || usage
check() { printf '%s' "$(stat -c'%A' "$1")" | sha256sum | xxd -r -p | base64 | head -c8; } # TODO head/dd # TODO source lib.sh
SH
cat >> /tmp/check_perm <<SH
printf '$token_format' "\$(check "\$1")"
SH

render_perm() {
	case "$1" in
		rwx) echo 'all' ;;
		rw-) echo 'read and write' ;;
		r-x) echo 'read and execute' ;;
		r--) echo 'only read' ;;
		-wx) echo 'write and execute' ;;
		-w-) echo 'only write' ;;
		--x) echo 'only execute' ;;
		---) echo 'no' ;;
	esac
}
echo "$perms" | cut -c2- | sed 's/.../& /g' | {
	read -r user group other;
	task "Enable $(render_perm "$user") permissions for user, $(render_perm "$group") permissions for group, and $(render_perm "$other") permissions for others for the file '$filename' -- then run: check_perm '$filename';"
}

