#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task
(
token_format "$level" "$(mac64 /etc)" | while parse_token; do
	task "From directory /home/$STUDENT/, show a command to change to the 'etc' directory inside the file system root (i.e. '/'). Get the token by running: [4mcheck cd $level $mac your command[0m"
done
)
