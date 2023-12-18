#!/bin/sh

. ./lib.sh

: "${current_level:?must be set}"

num_dirs=32

root="$1"
test -d "$root" || mkdir -p "$root" || exit 1
cd "$root"
root="$PWD" # get absolute path

# TODO create readme
exec 2> README

rand_leaf_dir() { find "$1" -type d -links 2 | pick_random; }
rand_dir() { find "$1" -type d | pick_random; }
rand_cd() { cd "$(rand_dir "$root")"; }
rand_cd_leaf() { cd "$(rand_leaf_dir "$root")"; }

mkdirs() { for _ in $(seq "${1:-2}"); do mkdir "$(random_filename)"; done; }
mkfiles() { for _ in $(seq "${1:-4}"); do touch "$(random_filename)"; done; }
mkfaketokens() { for _ in $(seq "${2:-4}"); do touch "$(fake_token "$1")"; done; }

for _ in $(seq "$num_dirs"); do
	rand_cd
	mkdirs
	mkfiles
done

## find -name
next_task
(
	task "Token is in file with name containing '$COURSE' and with extension '.token'"
	rand_cd_leaf
	current_token > "$COURSE-$(random_alnum).token"
)

## find -iname
next_task
(
	tag="$(random_alnum)"
	task "Token is in file with name containing '$(echo "$tag" | to_lower)' (case-insensitive)"
	rand_cd_leaf
	current_token > "$(random_alnum)$tag$(random_alnum)"
)

## find -mtime
next_task
(
	age="$(random_int 2 8)"
	task "Token is the name of the file which is older than $age years"
	rand_cd_leaf
	touch -d "$((age+1)) years ago" "$(current_token)"
	mkfaketokens "$(level)"
)

## find -size
next_task
(
	size="$(random_int 256 1024)"
	task "Token is in last line of file which has a size greater than $size bytes"
	rand_cd_leaf
	{ random_alnum "$size" | fold; echo; current_token; } > "$(uniq_filename)"
	mkfaketokens "$(level)"
)

## find -size exactly
next_task
(
	rand_cd_leaf
	file="$(current_token)"
	random_alnum "$(random_int 256 1024)" > "$file"
	task "Token is in file which has a size of exactly $(wc -c < "$file") bytes"
	mkfaketokens "$(level)"
)

token_file() {
	file="$(token "$1")"
	touch "$file"
	printf '%s\n' "$file"
}

## find -perm
next_task
(
	rand_cd_leaf
	file="$(token_file "$(level)")"
	chmod "$(random_perm)" "$file"
	task "Token is the name of file with permissions '$(stat -c'%#a' "$file")'"
	mkfaketokens "$(level)"
)

## find -perm (symbolic)
next_task
(
	rand_cd_leaf
	file="$(token_file "$(level)")"
	chmod "$(random_perm_chmod)" "$file"
	task "Token is name of file with permissions '$(stat -c'%A' "$file")'"
	mkfaketokens "$(level)"
)

## find -type d -name
next_task
(
	rand_cd_leaf
	dir="$(rand_mkdir)"
	current_token > "$dir/$(random_filename)"
	for _ in $(random_seq 4 16); do rand_cd && touch "$dir"; done
	task "Token is in a file in directory with name '$dir'"
)

## find multiple tests
next_task
(
	size="$(random_int 256 1024)"
	age="$(random_int 8 32)"
	perm="$(random_perm)"

	tok() {
		rand_cd_leaf

		action=${1:?provide mode: token/fake_token}
		file="$("$action" "$(level)")"
		: > "$file"
		shift

		for attr; do
			case "$attr" in
				size) random_alnum "$size" > "$file" ;;
				perm) chmod "$perm" "$file" ;;
				age) touch -d "$((age+1)) weeks ago" "$file" ;;
			esac
		done

		test "$action" = token && task "Token is name of file with size $(wc -c < "$file") bytes and permissions $(stat -c'%#a' "$file"), last modified $age weeks ago"
	}

	# real token:
	tok token size perm age

	# fake tokens:
	for _ in $(random_seq 4 8); do
		tok fake_token size perm
		tok fake_token size age
		tok fake_token perm age

		for attr in size perm age; do tok fake_token "$attr"; done
	done
)

## find empty file
next_task
(
	rand_cd_leaf
	file="$(token_file "$(level)")"
	for _ in $(random_seq 16 64); do
		random_alnum > "$(fake_token "$(level)")"
		mkdir -p "$(fake_token "$(level)")"
	done
	task "Token is the name of the only empty file in directory ${PWD#$root/}"
)

## find empty dir
next_task
(
	rand_cd_leaf
	dir="$(token "$(level)")"
	mkdir "$dir"
	for _ in $(random_seq 16 64); do
		fake="$(fake_token "$(level)")"
		mkdir -p "$fake"
		touch "$fake/$(random_filename)"
	done
	task "Token is the name of the only empty directory in ${PWD#$root/}"
)


# TODO find by owner

# TODO bonus: find -exec xxx {} \; print
