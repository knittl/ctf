#!/bin/sh

. ./lib.sh

root="$1"

test -d "$root" || mkdir -p "$root" || exit 1

cd "$root"
root="$PWD" # get absolute path

dir="$(rand_mkdir)"
cd "$dir"
for _ in $(random_seq 8 16); do touch "$(random_filename)"; done
echo "$(token 1-1)" > "$(find -type f | pick_random)"
task "Token is content of the only non-empty file in directory '$dir/'"
cd "$root"

echo "$(token 1-2)" | while parse_token; do
	printf '%s' "$course" > part0
	printf '%s' '{' > part1
	printf '%s' "$exercise" > part2
	printf '%s' ':' > part3
	printf '%s' "$student" > part4
	printf '%s' ':' > part5
	printf '%s' "$nonce" > part6
	printf '%s' ':' > part7
	printf '%s' "$mac" > part8
	printf '%s\n' '}' > part9
done
task "Token is in files 'part0' through 'part9', sorted alphabetically"

file="$(random_filename) $(random_filename) $(random_filename)"
token 1-3 > "$file"
task 'Token is in file with spaces in its name'

prefix="$(random_filename)"
suffix="$(random_filename)"
for _ in $(random_seq 8 32); do
	fake_token 1-4 > "$prefix$(random_filename)$suffix"
done
token 1-4 > "$prefix*$suffix"
task 'Token is in file with asterisk (*) in its name'
