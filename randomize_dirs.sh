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
mkdir ".$(current_token)"
task 'Navigate the directory tree to find the hidden directory with the token as name'

# TODO wildcards
