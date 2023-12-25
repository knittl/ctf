#!/bin/sh

. ./lib.sh

: "${current_level:?must be set}"

init_root "$1"

exec 2> README

## first line
next_task
file="$(rand_touch)"
task "Token is in first line of '$file'"
{
	lines="$(random_int 64 256)"
	current_token
	random_alnum "$((lines*64))" | fold -w64
} > "$file"

## extract cells
next_task
file="$(rand_touch)"
lines="$(random_int 32 128)"
line="$(random_int 32 "$lines")"
line="$(random_int 4 16)" # TODO first line, one of first few lines?
for i in $(seq "$lines"); do
	columns="$(random_int 4 16)"
	column="$(random_int 4 "$columns")"
	for j in $(seq "$columns"); do
		if test "$i" -eq "$line" && test "$j" -eq "$column"; then
			task "Token is in line $line, col $column in file '$file'"
			current_token
		else
			# TODO add other text too?
			fake_token "$level"
		fi
	done | paste -sd '\t'
done > "$file"
# TODO this setup very expensive

## custom delimiter
next_task
user="$(random_alnum)"
cat <<EOF > passwd
CTF-$user:x:1042:1042:$(token 1-1 | tr : ,):/tmp:/bin/false
EOF
task "Token is in comment field of user '$user' in file 'passwd'"

## text search
next_task
while include="$(random_alnum 4)" exclude="$(random_alnum 4)"; do
	test "$include" != "$exclude" && break
done

task "Token is in comment of usernames which contain '$include' but not '$exclude' in file 'passwd'"
i=1
current_token | tr ':' '\n' |
while read -r part; do
	print_passwd_entry() {
		name="$COURSE-$(random_alnum)${2:+-$2}"
		printf '%s:x:%d:%d:%s:/tmp:/bin/false\n' "$name" "$id" "$id" "$1"
	}

	id="$((1042+i))"
	: "$((i+=1))"
	print_passwd_entry "$part" "$include-$include"
	while chance 50; do
		id="$((1042+i))"
		: "$((i+=1))"
		print_passwd_entry "$(random_alnum)" "$include-$exclude"
	done
done >> passwd

## sorting
next_task
file="$(rand_touch)"
task "Token is in line with largest number in '$file'"
{
	for i in $(random_seq 256 512); do fake_token "$level"; done
	current_token
} | nl | shuf > "$file"

## frequency analysis
next_task
file="$(rand_touch)"
task "Token is line with highest frequency in '$file'"
freq="$(random_int 16)"
{
	for _ in $(random_seq 256 512); do
		token="$(fake_token "$level")"
		for _ in $(random_seq "$freq"); do
			echo "$token"
		done
	done

	token="$(current_token)"
	for _ in $(random_seq "$((freq+1))" "$((freq*2))"); do
		echo "$token"
	done
} | shuf > "$file"


## anchored text
next_task
file="$(rand_touch)"
tag="$(random_alnum)"
task "Token is in line which starts with '$tag' in file '$file'"
{
	printf '%s\t%s\t%s\n' "$tag" "$(current_token)" "$(random_alnum)"
	for _ in $(random_seq 256 512); do
		printf '%s\t%s\t%s\n' "$(random_alnum)" "$(fake_token "$level")" "$tag"
	done
} | shuf > "$file"


## text with multiple anchors
next_task
file="$(rand_touch)"
start="$(random_alnum)"
end="$(random_alnum)"
task "Token is in line which starts with '$start' and ends with '$end' in file '$file'"
{
	line() { printf '%s\t%s\t%s\n' "$1" "$2" "$3"; }
	line "$start" "$(current_token)" "$end"
	for _ in $(random_seq 256 512); do
		case "$(random_int 5)" in
			1) line "$start" "$(fake_token "$level")" "$(random_alnum)" ;;
			2) line "$(random_alnum)" "$(fake_token "$level")" "$end" ;;
			3) line "$(random_alnum)" "$(fake_token "$level")" "$start" ;;
			4) line "$end" "$(fake_token "$level")" "$(random_alnum)" ;;
			5) line "$(random_alnum)" "$(fake_token "$level")" "$(random_alnum)" ;;
		esac
	done
} | shuf > "$file"


## multiple conditions
next_task
file="$(rand_touch)"
start="$(random_alnum)"
end="$(random_alnum)"
task "Token is in line which starts with '$start' but does not end with '$end' in file '$file'"
{
	line() { printf '%s\t%s\t%s\n' "$1" "$2" "$3"; }
	line "$start" "$(current_token)" "$(random_alnum)"
	for _ in $(random_seq 256 512); do
		case "$(random_int 5)" in
			1) line "$start" "$(fake_token "$level")" "$end" ;;
			2) line "$(random_alnum)" "$(fake_token "$level")" "$end" ;;
			3) line "$(random_alnum)" "$(fake_token "$level")" "$start" ;;
			4) line "$end" "$(fake_token "$level")" "$(random_alnum)" ;;
			5) line "$(random_alnum)" "$(fake_token "$level")" "$(random_alnum)" ;;
		esac
	done
} | shuf > "$file"


## exclude text
next_task
file="$(rand_touch)"
tag="$(random_alnum)"
task "Token is in line which does not contain '$tag' in file '$file'"
{
	printf '%s %s\n' "$(random_alnum)" "$(current_token)"
	for _ in $(random_seq 256 512); do
		printf '%s %s\n' "$tag" "$(fake_token "$level")"
	done
} | shuf > "$file"

## ignore case
next_task
file="$(rand_touch)"
until tag="$(random_alnum | grep '[a-z]' | grep '[A-Z]')"; do :; done
task "Token is in line which contains '$(printf '%s' "$tag"|to_lower)' in mixed case in file '$file'"
{
	printf '%s\t%s\n' "$(random_alnum)$tag$(random_alnum)" "$(current_token)"
	for _ in $(random_seq 256 512); do
		printf '%s\t%s\n' "$(random_alnum)$(random_alnum)$(random_alnum)" "$(fake_token "$level")"
	done
} | shuf > "$file"

## match numbers
next_task
file="$(rand_touch)"
task "Token is in line which starts with numbers in file '$file'"
{
	printf '%s\t%s\n' "$(random_digits)$(random_alnum)" "$(current_token)"
	for _ in $(random_seq 256 512); do
		printf '%s\t%s\n' "$(random_alpha)$(random_alnum)" "$(fake_token "$level")"
	done
} | shuf > "$file"
