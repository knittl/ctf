#!/bin/sh

. ./lib.sh

: "${current_level:?must be set}"

num_dirs=8

root="${1:?root missing}"
test -d "$root" || mkdir -p "$root"
cd "$root"
root="$PWD" # get absolute path

exec 2> README

rand_dir() { find "$1" -type d | pick_random; }
rand_cd() { cd "$(rand_dir "$root")"; }

mkdirs() { for _ in $(seq "${1:-2}"); do mkdir "$(random_filename)"; done; }
mkfiles() { for _ in $(seq "${1:-4}"); do touch "$(random_filename)"; done; }

for _ in $(seq "$num_dirs"); do
	rand_cd
	mkdirs
	mkfiles
done

next_task
cd "$root"
file="$(rand_touch "$(random_alnum)")"
current_token > "$file"
task "Type \"cat '${PWD#$root}$file'\" to get the first token" # TODO correct path

next_task
rand_cd
mkdir "$(current_token)"
task 'Navigate the directory tree to find the directory with the token as name'

next_task
rand_cd
mkdir ".$(current_token)"
task 'Navigate the directory tree to find the hidden directory with the token as name'

next_task
(
	rand_cd
	current_task="${current_task}.a"
	file="$(rand_touch "$(current_token)")" # TODO better file name?
	task 'Token is the name of a file'

	current_task="${current_task%.a}.b"
	current_token > "$file"
	task "Token is in the content of file with token name $(level)"
)

next_task
(
	rand_cd
	touch ".$(current_token)" # TODO
	task 'Token is the name of a hidden file'
)

next_task
(
	rand_cd
	current_task="${current_task}.a"
	file="$(rand_touch "-$(current_token)")"
	task 'Token is the name of a file that has a name starting with a hyphen'

	current_task="${current_task%.a}.b"
	current_token > "$file"
	task "Token is in the file with token name $(level)"
)

# TODO wildcards
