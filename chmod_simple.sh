#!/bin/sh

. ./lib.sh

init_root "$1"
exec 2> README

dir="$(rand_mkdir)"
chmod a+w "$dir"
cd "$dir"

# helpers
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
next_task
filename="$(rand_touch)"
chmod "$(random_perm)" "$filename"
perms="$(stat -c'%A' "$filename")"
chmod "$(random_perm)" "$filename"

token_format "$level" "$(mac64 "$perms")" | while parse_token; do
	echo "$perms" | cut -c2- | sed 's/.../& /g' | {
		read -r user group other;
		task "Enable $(render_perm "$user") permissions for user, $(render_perm "$group") permissions for group, and $(render_perm "$other") permissions for others for the file '$dir/$filename' -- then run: check perm $level $mac '$dir/$filename';"
	}
done

## perms (numeric)
next_task
filename="$(rand_touch)"
chmod "$(random_perm)" "$filename"
perms="$(stat -c'%A' "$filename")"
perms_octal="$(stat -c'%#a' "$filename")"
chmod "$(random_perm)" "$filename"

token_format "$level" "$(mac64 "$perms")" | while parse_token; do
	task "Set the octal permissions '$perms_octal' for the file '$dir/$filename' -- then run: check perm $level $mac '$dir/$filename';"
done

## perms (symbolic)
next_task
filename="$(rand_touch)"
chmod "$(random_perm)" "$filename"
perms="$(stat -c'%A' "$filename")"
chmod "$(random_perm)" "$filename"

token_format "$level" "$(mac64 "$perms")" | while parse_token; do
	task "Set permissions '${perms#-}' for the file '$dir/$filename' -- then run: check perm $level $mac '$dir/$filename';"
done

## create + mode
next_task
type="$(pick_random d -)"
path="$(uniq_filename)"
pathtype=file; test "$type" = d && pathtype=directory
perms="$(random_perm_sym)"

token_format "$level" "$(mac64 "$type$perms")" | while parse_token; do
echo "$level" "$mac"
	task "Create $pathtype '$dir/$path' with permissions '$perms' -- then run: check perm $level $mac '$dir/$path';"
done
