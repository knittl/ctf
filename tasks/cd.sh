#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task
token_format "$level" "$(mac64 /etc)" | while parse_token; do
	task "Show a command to change to the 'etc' directory inside the file system root (i.e. '/'). The command has to work regardless of your current directory. Get the token by running: $(bold "check cd $level $mac") $(underlined 'your command')"
done

# TODO relative directory change
