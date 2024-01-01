#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

num_dirs=8

rand_dir() { find "$1" -type d | pick_random; }
rand_cd() { cd "$(rand_dir "$root")"; }

mkdirs() { repeat "${1:-2}" rand_mkdir; }
mkfiles() { repeat "${1:-4}" rand_touch; }

for _ in $(seq "$num_dirs"); do
	rand_cd
	mkdirs
	mkfiles
done

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
	current_subtask=a
	file="$(rand_touch "$(current_token)")" # TODO better file name?
	task 'Token is the name of a file'

	current_subtask=b
	current_token > "$file"
	task "Token is in the content of file with token name $(current_subtask=a level)"
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
	current_subtask=a
	file="$(rand_touch "-$(current_token)")"
	task 'Token is the name of a file that has a name starting with a hyphen'

	current_subtask=b
	current_token > "$file"
	task "Token is in the file with token name $(current_subtask=a level)"
)

# TODO wildcards
