#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task
token_format "$level" "$(mac64 /etc)" | while parse_token; do
	task "Show a command to change to the 'etc' directory inside the file system root (i.e. '/'). The command has to work independently of your current directory. Get the token by running: $(bold "check cd $level $mac a") $(underlined 'your command')"
done

next_task
token_format "$level" "$(mac64 /bin)" | while parse_token; do
	task "The output of $(bold pwd) is '/home/$STUDENT'. Show a command to change to the 'bin' directory inside the file system root (i.e. '/'). The command must use a relative path. Get the token by running: $(bold "check cd $level $mac r") $(underlined 'your command')"
done

# TODO relative directory change

next_task
filename="$(uniq_filename)"
token_format "$level" "$(mac64 "0/home/$STUDENT/$filename")" | while parse_token; do
	task "Create an empty file with name '$filename' in directory /home/$STUDENT/. Get the token by running: $(bold "check emptyfile $level $mac") $(underlined "/home/$STUDENT/$filename")"
done

next_task
(
	dir="$(rand_mkdir)"
	cd "$dir"

	for ext in jpg jpeg png gif; do
		for _ in $(random_seq 8 16); do
			touch "$(random_filename).$ext"
		done
	done

	token_format "$level" "$(ls -l *.j* | mac64)" | while parse_token; do
		task "How can you list details (size, date, ...) about all (non-hidden) $(bold jpg) and $(bold jpeg) image files in the directory '$dir' with a single command? Get the token by running: $(bold "check details $level $mac") $(underlined your command)"
	done

	for ext in jar j2k jbg jfif jiff jpg.gz json; do
		for _ in $(random_seq 8 16); do
			touch "$(random_filename).$ext"
		done
	done
)
