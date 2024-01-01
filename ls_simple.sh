#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

# token in target of softlink
next_task
filename="$(uniq_filename)"
ln -s "$(current_token)" "$filename"
task "Token is target of symbolic link '$filename'"
