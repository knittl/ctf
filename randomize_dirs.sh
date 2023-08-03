#!/bin/sh

. ./lib.sh

root="${1:?root missing}"
num_dirs=8

test -d "$root" || mkdir -p "$root"

cd "$root"
root="$PWD" # get absolute path

rand_dir() { find "$1" -type d | pick_random; }
rand_cd() { cd "$(rand_dir "$root")"; }

mkdirs() { seq "${1:-2}" | while read _; do mkdir "$(random_filename)"; done; }
mkfiles() { seq "${1:-4}" | while read _; do touch "$(random_filename)"; done; }

seq "$num_dirs" | while read _; do
	rand_cd
	mkdirs
	mkfiles
done

cd "$root"
file="$(rand_touch "$(random_alnum)")"
token 2-0 > "$file"
task "Type \"cat '${PWD#$root}$file'\" to get the first token" # TODO correct path

rand_cd
mkdir "$(token 2-1)"
task 'Navigate the directory tree to find the directory with the token as name'

rand_cd
mkdir ".$(token 2-2)"
task 'Navigate the directory tree to find the hidden directory with the token as name'

rand_cd
file="$(rand_touch "$(token 2-3)")" # TODO better file name?
task 'Token is the name of a file'
token 2-4 > "$file"
task 'Token is in the content of file with token name 2-3'

rand_cd
touch ".$(token 2-5)" # TODO
task 'Token is the name of a hidden file'

rand_cd
file="$(rand_touch "-$(token 2-6)")"
task 'Token is the name of a file that has a name starting with a hyphen'
token 2-7 > "$file"
task 'Token is in the file with token name 2-6'

# TODO wildcards
