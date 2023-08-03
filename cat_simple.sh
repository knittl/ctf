#!/bin/sh

. ./lib.sh

root="$1"
num_files=8
max_name_len=16

test -d "$root" || mkdir -p "$root"

cd "$root"
root="$PWD" # get absolute path

for _ in $(seq "$num_files"); do touch "$(random_filename)"; done
echo "$(token 1-1)" > "$(find -type f | pick_random)"
task 'Token is content of the only non-empty file'

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
