#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task # 1
(
file="$(rand_touch)"
current_token > "$file"
task "Type $(bold "cat '${PWD#$root}$file'") to get the first token." # TODO correct path
)

rand_fhs_dir() {
	dir=/
	while [ "$dir" = / ] || [ "$dir" = /ctf ]; do dir="$(find / -maxdepth 1 -type d -perm /o+x | pick_random)"; done
	echo "$dir"
}

next_task # 2
(
dir="$(rand_fhs_dir)"
prepare_current_token "$dir"
task "Show a $(bold single) command to change to the '$(bold "${dir#/}")' directory inside the file system root (i.e. '/').  The command has to work independently of your current directory.  Get the token by running: $(bold "$(print_check cd a)") $(underlined your command)"
)

next_task # 3
(
dir="$(rand_fhs_dir)"
prepare_current_token "$dir"
task "The output of $(bold pwd) is '$(bold "/home/$STUDENT")'.  Show a $(bold single) command to change to the '$(bold "${dir#/}")' directory inside the file system root (i.e. '/').  The command must use a $(bold relative) path.  Get the token by running: $(bold "$(print_check cd r)") $(underlined 'your command')"
)

next_task # 4
(
filename="$(uniq_filename)"
prepare_current_token "0/home/$STUDENT/$filename"
task "Create an $(bold empty file) with name '$(bold "$filename")' in directory $(bold "/home/$STUDENT/").  Get the token by running: $(bold "$(print_check emptyfile "/home/$STUDENT/$filename")")"
)

next_task # 5
(
dir="$(rand_mkdir)"
cd -- "$dir"

mk_files() {
	for ext; do
		for _ in $(random_seq 8 16); do
			touch -d "$(random_int 0 16) months ago $(random_int 0 8) days ago $(random_int 0 1024) minutes ago" "$(random_filename).$ext"
		done
	done
}

mk_files jpg jpeg

prepare_current_token "$(ls -l *)"
task "How can you list details (size, date, ...) about all (non-hidden) $(bold jpg) and $(bold jpeg) image files in the directory '$(bold "$dir")' with a single command? Get the token by running: $(bold "$(print_check details)") $(underlined your command)"

mk_files png gif jar j2k jbg jfif jiff jpg.gz json
)

next_task # 6
(
dir="$(rand_mkdir)"
cd -- "$dir"

ext() { pick_random txt jpg png gif mkv blend html css js ts svg zip json ods odt odp; }
names=$(
	for _ in $(random_seq 128 256); do
		age="$(random_int 0 16) months ago $(random_int 0 8) days ago $(random_int 0 1024) minutes ago"
		name="$(random_filename).$(ext)"
		touch -d "$age" "$name" && printf '%s\n' "$name"
	done | sort -u
)

prepare_current_token "$names"
task "How can you save a simple list of the files in directory '$(bold "$dir")' into a file? Execute the command to write the file and then run: $(bold "$(print_check cat)") $(underlined path/to/your/file)"
)

next_task # 7
(
count="$(random_int 4 8)"
wildcard="$(random_alnum 4)_*/*[$(random_alpha $(random_int 4 8))]/$(printf "%$(random_int 2 4)s" | tr ' ' '?').*"
prepare_current_token "$(printf '%d\n%s\n' "$count" "$wildcard")"
task "Create a directory which contains $(bold "exactly $count") files which match the wildcard pattern '$(bold "$wildcard")'.  Then run $(bold "$(print_check glob "$count" "$wildcard")") $(underlined path/to/directory)"
)

next_task # 8
(
dirname="$(rand_mkdir)"
cd "$dirname"
repeat "$(random_int 4 8)" rand_mkdir >/dev/null
touch "$(find */ -type d | pick_random)/$(current_token)"
task "The token is the name of the only file in a random subdirectory of '$(bold "$dirname")'.  Navigate with $(bold ls) and find the file."
)

next_task # 9
(
dir="$(rand_mkdir)"
cd -- "$dir"
repeat "$(random_int 8 16)" rand_touch >/dev/null
current_token > "$(find -type f | pick_random)"
task "The token is in the content of the only $(bold non-empty) file in directory '$(bold "$dir/")'"
)
