#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task
token_format "$level" "$(mac64 /etc)" | while parse_token; do
	task "Show a command to change to the 'etc' directory inside the file system root (i.e. '/'). The command has to work independently of your current directory. Get the token by running: $(bold "check cd $level $mac a") $(underlined your command)"
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

	mk_files() {
		for ext; do
			for _ in $(random_seq 8 16); do
				touch -d "$(random_int 0 16) months ago $(random_int 0 8) days ago $(random_int 0 1024) minutes ago" "$(random_filename).$ext"
			done
		done
	}

	mk_files jpg jpeg

	token_format "$level" "$(ls -l * | mac64)" | while parse_token; do
		task "How can you list details (size, date, ...) about all (non-hidden) $(bold jpg) and $(bold jpeg) image files in the directory '$dir' with a single command? Get the token by running: $(bold "check details $level $mac") $(underlined your command)"
	done

	mk_files png gif jar j2k jbg jfif jiff jpg.gz json
)

next_task
(
	dir="$(rand_mkdir)"
	cd "$dir"

	ext() { pick_random txt jpg png gif mkv blend html css js ts; }
	names=$(
		for _ in $(random_seq 128 256); do
			age="$(random_int 0 16) months ago $(random_int 0 8) days ago $(random_int 0 1024) minutes ago"
			name="$(random_filename).$(ext)"
			touch -d "$age" "$name" && echo "$name"
		done | sort -u
	)

	token_format "$level" "$(mac64 "$names")" | while parse_token; do
		task "How can you save a simple list of the files in directory '$dir' into a file? Execute the command to write the file and then run: $(bold "check cat $level $mac") $(underlined path/to/your/file)"
	done
)

next_task
(
	count="$(random_int 4 8)"
	wildcard="$(random_alnum 4)_*/*[$(random_alpha $(random_int 4 8))]/$(printf "%$(random_int 2 4)s" | tr ' ' '?').*"
	token_format "$level" "$(printf '%d\n%s\n' "$count" "$wildcard" | mac64)" | while parse_token; do
		task "Create a directory which contains exactly $count files which match the wildcard pattern '$wildcard'. Then run $(bold "check glob $level $mac $count '$wildcard'") $(underlined path/to/directory)"
	done
)
