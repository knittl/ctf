#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

rand_leaf_dir() { find "$1" -type d -links 2 | pick_random; }
rand_dir() { find "$1" -type d | pick_random; }
rand_cd() { cd "$(rand_dir "$root")"; }
rand_cd_leaf() { cd "$(rand_leaf_dir "$root")"; }

mkdirs() { repeat "${1:-2}" rand_mkdir; } >/dev/null
mkfiles() { repeat "${1:-4}" rand_touch; } >/dev/null
touch_fake_token() { touch -- "$(current_fake_token)"; }
mkfaketokens() { repeat "${2:-4}" touch_fake_token; }

current_token_file() { rand_touch "$(current_token)"; }

(
for _ in $(seq 32); do
	rand_cd
	mkdirs
	mkfiles
done
)

next_task # 1 find by name
(
rand_cd_leaf
current_token > "$COURSE-$(random_alnum).token"
task "The token is in the file with name $(bold containing) '$(bold "$COURSE")' and with extension '$(bold ".token")'"
)

next_task # 2 find by name insensitive
(
rand_cd_leaf
tag="$(random_alnum)"
current_token > "$(random_alnum)$tag$(random_alnum)"
task "The token is in file with name $(bold containing) '$(bold "$(echo "$tag" | to_lower)")' ($(bold case-insensitive))"
)

next_task # 3 find by modification time
(
rand_cd_leaf
age="$(random_int 2 8)"
touch -d "$((age+1)) years ago" "$(current_token)"
mkfaketokens
task "The token is the $(bold name) of the file which is $(bold "older than $age years")"
)

next_task # 4 find by size exact
(
rand_cd_leaf
file="$(current_token)"
random_alnum "$(random_int 256 1024)" > "$file"
mkfaketokens
task "The token is in the file which has a size of $(bold "exactly $(wc -c < "$file") bytes")"
)

next_task # 5 find by size greater
(
rand_cd_leaf
size="$(random_int 256 1024)"
{ random_alnum "$size" | fold; echo; current_token; } > "$(uniq_filename)"
mkfaketokens
task "The token is in the $(bold last line) of the file which has a $(bold size greater than $size bytes)"
)

next_task # 6 find by permission (numeric)
(
rand_cd_leaf
file="$(current_token_file)"
chmod "$(random_perm)" "$file"
mkfaketokens
task "The token is the $(bold name) of file with $(bold permissions) '$(bold "$(stat -c'%#a' "$file")")'"
)

next_task # 7 find by permission (symbolic)
(
rand_cd_leaf
file="$(current_token_file)"
chmod "$(random_perm_chmod)" "$file"
mkfaketokens
task "The token is the $(bold name) of file with $(bold permissions) '$(bold "$(stat -c'%A' "$file")")'"
)

next_task # 8 find file in directory
(
rand_cd_leaf
dir="$(rand_mkdir)"
current_token > "$dir/$(random_filename)"
for _ in $(random_seq 4 16); do rand_cd && touch -- "$dir"; done
task "The token is in a file inside a directory with the name '$(bold "$dir/")'"
)

next_task # 9 find multiple criteria
(
size="$(random_int 256 1024)"
age="$(random_int 8 32)"
perm="$(random_perm)"

tok() {
	rand_cd_leaf

	action=${1:?provide mode: current_token/current_fake_token}
	file="$("$action")"
	: > "$file"
	shift

	for attr; do
		case "$attr" in
			size) random_alnum "$size" > "$file" ;;
			perm) chmod "$perm" "$file" ;;
			age) touch -d "$((age+1)) weeks ago" -- "$file" ;;
		esac
	done
}

# real token:
tok current_token size perm age
task "The token is $(bold name) of file with $(bold "size $(wc -c < "$file") bytes") and $(bold "permissions $(stat -c'%#a' "$file")"), $(bold "last modified over $age weeks ago")"

# fake tokens:
for _ in $(random_seq 4 8); do
	tok current_fake_token size perm
	tok current_fake_token size age
	tok current_fake_token perm age

	for attr in size perm age; do tok current_fake_token "$attr"; done
done
)

next_task # 10 find empty file
(
rand_cd_leaf
file="$(current_token_file)"
for _ in $(random_seq 16 64); do
	random_alnum > "$(current_fake_token)"
	mkdir -p "$(current_fake_token)"
done
task "The token is the name of the only $(bold empty file) in directory '$(bold "${PWD#$root/}")'"
)

next_task # 11 find empty dir
(
rand_cd_leaf
dir="$(current_token)"
mkdir -p "$dir"
for _ in $(random_seq 16 64); do
	fake="$(current_fake_token)"
	mkdir -p "$fake"
	touch -- "$fake/$(random_filename)"
done
task "The token is the name of the only $(bold empty directory) in '$(bold "${PWD#$root/}")'"
)
