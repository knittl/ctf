#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

dir="$(rand_mkdir)"
chmod a+w "$dir"
cd_dir() { cd -- "$dir"; }

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

rand_perm_touch() {
	filename="$(rand_touch)"
	chmod "$(random_perm)" "$filename"
	echo "$filename"
}

#####

next_task # 1 perms (textual)
(
cd_dir
filename="$(rand_perm_touch)"
perms="$(stat -c'%A' "$filename")"
chmod "$(random_perm)" "$filename"

prepare_current_token "$perms"
echo "$perms" | cut -c2- | sed 's/.../& /g' | while read -r user group other _; do
	task "Enable $(render_perm "$user") permissions for user, $(render_perm "$group") permissions for group, and $(render_perm "$other") permissions for others for the file '$(bold "$dir/$filename")' -- then run: $(bold "$(print_check perm "$dir/$filename")")"
done
)

next_task # 2 perms (numeric)
(
cd_dir
filename="$(rand_perm_touch)"
perms="$(stat -c'%A' "$filename")"
perms_octal="$(stat -c'%04a' "$filename")"
chmod "$(random_perm)" "$filename"

prepare_current_token "$perms"
task "Set the octal permissions $(bold "'$perms_octal'") for the file '$(bold "$dir/$filename")' -- then run: $(bold "$(print_check perm "$dir/$filename")")"
)

next_task # 3 perms (symbolic)
(
cd_dir
filename="$(rand_perm_touch)"
perms="$(stat -c'%A' "$filename")"
chmod "$(random_perm)" "$filename"

prepare_current_token "$perms"
task "Set permissions $(bold "'${perms#-}'") for the file '$(bold "$dir/$filename")' -- then run: $(bold "$(print_check perm "$dir/$filename")")"
)

next_task # 4 create + mode
(
type="$(pick_random d -)"
path="$(uniq_filename)"
case "$type" in
	d) pathtype=directory ;;
	-) pathtype=file ;;
esac
perms="$(random_perm_sym)"

prepare_current_token "$type$perms"
task "Create the $(bold "$pathtype") '$(bold "$dir/$path")' with permissions $(bold "'$perms'") -- then run: $(bold "$(print_check perm "$dir/$path")")"
)

next_task # 5 sorted ls
(
dirname="$(rand_mkdir)"
touch_ago() {
	ago="$1"
	touch -d "$1 years ago $1 month ago $1 week ago $1 day ago" "$2"
}

cd -- "$dirname"
current_token >/dev/null
year="$(random_int 10 20)"

touch_ago 1 "$course"
touch_ago 2 '{'
touch_ago 3 "$exercise"
touch_ago 4 ":$student:"
printf '%s:%s\n' "$nonce" "$mac" | fold -w3 | {
	ago=6
	while read -r c; do
		touch_ago "$ago" "$c"
		ago="$((ago+1))"
	done
	touch_ago "$ago" '}'
}
task "The token is all $(bold file names) in directory '$(bold "$dirname")' joined, sorted by modification date"
)

next_task # 6 split across files
(
prefix="$(random_alnum)"
current_token >/dev/null
printf '%s' "$course" > "${prefix}0"
printf '%s' '{' > "${prefix}1"
printf '%s' "$exercise" > "${prefix}2"
printf '%s' ':' > "${prefix}3"
printf '%s' "$student" > "${prefix}4"
printf '%s' ':' > "${prefix}5"
printf '%s' "$nonce" > "${prefix}6"
printf '%s' ':' > "${prefix}7"
printf '%s' "$mac" > "${prefix}8"
printf '%s\n' '}' > "${prefix}9"
task "The token is in the files '$(bold "${prefix}0")' through '$(bold "${prefix}9")', sorted alphabetically"
)

next_task # 7 spaces
(
file="$(random_filename) $(random_filename) $(random_filename)"
current_token > "$file"
task "The token is in the file with $(bold spaces) in its $(bold name)"
)

next_task # 8 wildcards
(
prefix="$(random_filename)"
suffix="$(random_filename)"
for _ in $(random_seq 8 32); do
	current_fake_token > "$prefix$(random_filename)$suffix"
done
current_token > "$prefix*$suffix"
task "The token is in the file with an $(bold 'asterisk (*)') in its $(bold name)"
)
