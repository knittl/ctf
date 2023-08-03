#!/bin/sh

. ./lib.sh

root="$1"
num_dirs=32

test -d "$root" || mkdir -p "$root"

cd "$root"
root="$PWD" # get absolute path

rand_dir() { find "$1" -type d | pick_random; }
rand_cd() { cd "$(rand_dir "$root")"; }

rand_leaf_dir() { find "$1" -type d -links 2 | pick_random; }
rand_dir() { find "$1" -type d | pick_random; }
rand_cd() { cd "$(rand_dir "$root")"; }
rand_cd_leaf() { cd "$(rand_dir "$root")"; }

mkdirs() { for _ in $(seq "${1:-2}"); do mkdir "$(random_filename)"; done; }
mkfiles() { for _ in $(seq "${1:-4}"); do touch "$(random_filename)"; done; }
mkfaketokens() { for _ in $(seq "${2:-4}"); do touch "$(fake_token "$1")"; done; }

for _ in $(seq "$num_dirs"); do
	rand_cd
	mkdirs
	mkfiles
done

## find -name
task "Token is in file with name containing '$COURSE' and with extension '.token'"
rand_cd_leaf
token 2-2 > "$COURSE-$(random_alnum).token"

## find -iname
tag="$(random_alnum)"
task "Token is in file with name containing '$(echo "$tag" | to_lower)' in any case"
rand_cd_leaf
token 2-3 > "$(random_alnum)$tag$(random_alnum)"

## find -mtime
age="$(random_int 2 8)"
task "Token is the name of the file which is older than $age years"
rand_cd_leaf
touch -d "$((age+1)) years ago" "$(token 2-4)"
mkfaketokens 2-4

## find -size
size="$(random_int 256 1024)"
task "Token is the name of the file which has a size greater than $size bytes"
rand_cd_leaf
{ random_alnum "$size" | fold; echo; token 2-5; } > "$(uniq_filename)"
mkfaketokens 2-5

## find -size exactly
rand_cd_leaf
file="$(token 2-6)"
random_alnum "$(random_int 256 1024)" > "$file"
task "Token is in file which has a size of exactly $(wc -c < "$file") bytes"
mkfaketokens 2-6

token_file() {
	file="$(token "$1")"
	touch "$file"
	printf '%s\n' "$file"
}

## find -perm
rand_cd_leaf
file="$(token_file 2-7)"
chmod "$(random_perm)" "$file"
task "Token is the name of file with permissions '$(stat -c'%#a' "$file")'"
mkfaketokens 2-7

## find -perm (symbolic)
rand_cd_leaf
file="$(token_file 2-8)"
chmod "$(random_perm_chmod)" "$file"
task "Token is name of file with permissions '$(stat -c'%A' "$file")'"
mkfaketokens 2-8

## find -type d -name
rand_cd_leaf
dir="$(rand_mkdir)"
token 2-9 > "$dir/$(random_filename)"
rand_cd_leaf
touch "$dir"
task "Token is in a file in directory with name '$dir'"

## find multiple tests
(
	rand_cd_leaf

	tok() {
		size="$(random_int 256 1024)"
		age="$(random_int 8 32)"
		perm="$(random_perm)"

		action=${1:?provide mode: token/fake_token}
		file="$("$action" 2-10)"
		: > "$file"
		shift

		for attr; do
			case "$attr" in
				size) random_alnum "$size" > "$file" ;;
				perm) chmod "$perm" "$file" ;;
				age) touch -d "$((age+1)) weeks ago" "$file" ;;
			esac
		done

		test "$action" = token && task "Token is name of file with size $size bytes and permissions $(stat -c'%#a' "$file"), last modified $age weeks ago"
	}

	# real token:
	tok token size perm age

	# fake tokens:
	tok fake_token size perm
	tok fake_token size age
	tok fake_token perm age

	tok fake_token size
	tok fake_token perm
	tok fake_token age
)

## find empty file
rand_cd_leaf
file="$(token_file 2-11)"
for _ in $(random_seq 16 64); do
	random_alnum > "$(fake_token 2-11)"
	mkdir -p "$(fake_token 2-11)"
done
task "Token is the name of the only empty file in directory ${PWD#$root/}"

## find empty dir
rand_cd_leaf
dir="$(token 2-12)"
mkdir "$dir"
for _ in $(random_seq 16 64); do
	fake="$(fake_token 2-12)"
	mkdir -p "$fake"
	touch "$fake/$(random_filename)"
done
task "Token is the name of the only empty directory in ${PWD#$root/}"



# TODO find by owner

# TODO bonus: find -exec xxx {} \; print
