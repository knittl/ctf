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

next_task
filename="$(uniq_filename)"
token_format "$level" "$(mac64 "0/home/$STUDENT/$filename")" | while parse_token; do
	task "Create an empty file with name '$filename' in directory /home/$STUDENT/. Get the token by running: $(bold "check emptyfile $level $mac") $(underlined "/home/$STUDENT/$filename")"
done
