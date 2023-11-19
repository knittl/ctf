#!/bin/sh

. ./lib.sh

root="${1?root dir missing}"
num_files=8

test -d "$root" || mkdir -p "$root"

cd "$root"
root="$PWD" # get absolute path

rand_dir() { find "$1" -type d | pick_random; }
rand_cd() { cd "$(rand_dir "$root")"; }

# helpers
mac64() {
	printf '%s\n' "$1" | sha256sum | xxd -r -p | base64 | take 8;
}

script='/tmp/check_perm'
> "$script"
chmod a+x "$script"
cat >> "$script" <<-\SH
#!/bin/sh
task="$1"; mac="$2"; file="$3"
if [ "$#" -ne 3 ]; then
	echo "$0: Usage: $0 TASK MAC FILENAME" >&2
	exit 1
fi
if ! [ -e "$file" ]; then
	echo "$0: No such file or directory: $file" >&2
	exit 1
fi
check() {
	stat -c'%A' "$file" |
		sha256sum |
		xxd -r -p |
		base64 |
		head -c8 # TODO head/dd # TODO source lib.sh
}
SH
cat >> "$script" <<-SH
printf '%s{%s:%s}' "$COURSE" "\$task:$STUDENT:\$(check "\$file")" "\$mac"
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

#####

## perms (textual)
filename="$(rand_touch)"
chmod "$(random_perm)" "$filename"
perms="$(stat -c'%A' "$filename")"
chmod "$(random_perm)" "$filename"

token_format 1-1 "$(mac64 "$perms")" | while parse_token; do
	echo "$perms" | cut -c2- | sed 's/.../& /g' | {
		read -r user group other;
		task "Enable $(render_perm "$user") permissions for user, $(render_perm "$group") permissions for group, and $(render_perm "$other") permissions for others for the file '$filename' -- then run: check_perm 1-1 $mac '$filename';"
	}
done

## perms (numeric)
filename="$(rand_touch)"
chmod "$(random_perm)" "$filename"
perms="$(stat -c'%A' "$filename")"
perms_octal="$(stat -c'%#a' "$filename")"
chmod "$(random_perm)" "$filename"

token_format 1-2 "$(mac64 "$perms")" | while parse_token; do
	task "Set the octal permissions '$perms_octal' for the file '$filename' -- then run: check_perm 1-2 $mac '$filename';"
done

## perms (symbolic)
filename="$(rand_touch)"
chmod "$(random_perm)" "$filename"
perms="$(stat -c'%A' "$filename")"
chmod "$(random_perm)" "$filename"

token_format 1-3 "$(mac64 "$perms")" | while parse_token; do
	task "Set permissions '${perms#?}' for the file '$filename' -- then run: check_perm 1-3 $mac '$filename';"
done

## TODO create file or dir, then set perms
