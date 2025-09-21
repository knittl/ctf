#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task # 1 head
(
file="$(rand_touch)"
lines="$(random_int 64 256)"
{
	current_token
	random_alnum "$((lines*64))" | fold -w64
} > "$file"
task "The token is in the $(bold first line) of file '$(bold "$file")'"
)

next_task # 2 head + cut with default delim (tab)
(
padding() {
	if chance 33
	then current_fake_token
	else printf '%s\n' "$(random_alnum)"
	fi
}
file="$(rand_touch)"
lines="$(random_int 32 128)"
line="$(random_int 32 "$lines")"
for i in $(seq "$lines"); do
	{
		columns="$(random_int 4 16)"
		if [ "$i" -eq "$line" ]; then
			column="$(random_int 2 "$columns")"
			repeat "$((column-1))" padding
			current_token
			repeat "$((columns-column-1))" padding
			task "The token is in $(bold "line $line, column/field $column") in file '$(bold "$file")'"
		else
			repeat "$columns" padding
		fi
	} | join_lines '\t'
done > "$file"
# TODO this setup is quite expensive
)

next_task # 3 sort (+tail)
(
file="$(rand_touch)"
{
	repeat "$(random_int 256 512)" current_fake_token
	current_token
} | nl | shuf > "$file"
task "The token is in the line with the $(bold largest number) in file '$(bold "$file")'"
)

next_task # 4 sort | uniq
(
file="$(rand_touch)"
freq="$(random_int 16)"
{
	for _ in $(random_seq 256 512); do
		token="$(current_fake_token)"
		tok() { echo "$token"; }
		repeat "$(random_int "$freq")" tok
	done

	token="$(current_token)"
	tok() { echo "$token"; }
	repeat "$(random_int  "$((freq+1))" "$((freq*2))")" tok
} | shuf > "$file"
task "The token is line with $(bold highest frequency) in the file '$(bold "$file")'"
)

next_task # 5 grep
(
file="$(rand_touch)"
tag="$(random_alnum)"
{
	printf '%s\t%s\t%s\n' "$tag" "$(current_token)" "$(random_alnum)"
	line() { printf '%s\t%s\t%s\n' "$(random_alnum)" "$(current_fake_token)" "$tag"; }
	repeat "$(random_int 256 512)" line
} | shuf > "$file"
task "The token is in the line which $(bold starts with) '$(bold "$tag")' in file '$(bold "$file")'"
)

next_task # 6 grep | grep or grep with regex
(
file="$(rand_touch)"
start="$(random_alnum)"
end="$(random_alnum)"
{
	line() { printf '%s\t%s\t%s\n' "$1" "$2" "$3"; }
	line "$start" "$(current_token)" "$end"
	for _ in $(random_seq 256 512); do
		case "$(random_int 5)" in
			1) line "$start" "$(current_fake_token)" "$(random_alnum)" ;;
			2) line "$(random_alnum)" "$(current_fake_token)" "$end" ;;
			3) line "$(random_alnum)" "$(current_fake_token)" "$start" ;;
			4) line "$end" "$(current_fake_token)" "$(random_alnum)" ;;
			5) line "$(random_alnum)" "$(current_fake_token)" "$(random_alnum)" ;;
		esac
	done
} | shuf > "$file"
task "The token is in the line which $(bold starts with) '$(bold "$start")' and $(bold ends with) '$(bold "$end")' in file '$(bold "$file")'"
)

next_task # 7 grep | grep -v
(
file="$(rand_touch)"
start="$(random_alnum)"
end="$(random_alnum)"
{
	line() { printf '%s\t%s\t%s\n' "$1" "$2" "$3"; }
	line "$start" "$(current_token)" "$(random_alnum)"
	for _ in $(random_seq 256 512); do
		case "$(random_int 5)" in
			1) line "$start" "$(current_fake_token)" "$end" ;;
			2) line "$(random_alnum)" "$(current_fake_token)" "$end" ;;
			3) line "$(random_alnum)" "$(current_fake_token)" "$start" ;;
			4) line "$end" "$(current_fake_token)" "$(random_alnum)" ;;
			5) line "$(random_alnum)" "$(current_fake_token)" "$(random_alnum)" ;;
		esac
	done
} | shuf > "$file"
task "The token is in the line which $(bold starts with) '$(bold "$start")' but does $(bold not end with) '$(bold "$end")' in file '$(bold "$file")'"
)

next_task # 8 grep -v
(
file="$(rand_touch)"
tag="$(random_alnum)"
{
	printf '%s %s\n' "$(random_alnum)" "$(current_token)"
	for _ in $(random_seq 256 512); do
		printf '%s %s\n' "$tag" "$(current_fake_token)"
	done
} | shuf > "$file"
task "The token is in the line which does $(bold not contain) '$(bold "$tag")' in file '$(bold "$file")'"
)

next_task # 9 grep -i
(
file="$(rand_touch)"
until tag="$(random_alpha | grep '[[:lower:]]' | grep '[[:upper:]]')"; do :; done
{
	printf '%s\t%s\n' "$(random_alnum)$tag$(random_alnum)" "$(current_token)"
	for _ in $(random_seq 256 512); do
		printf '%s\t%s\n' "$(random_alnum)$(random_alnum)$(random_alnum)" "$(current_fake_token)"
	done
} | shuf > "$file"
task "The token is in the line which $(bold contains) '$(bold "$(printf '%s' "$tag"|to_lower)")' in $(bold mixed case) in the file '$(bold "$file")'"
)

next_task # 10 grep numbers
(
file="$(rand_touch)"
{
	printf '%s\t%s\n' "$(random_digits)$(random_alnum)" "$(current_token)"
	for _ in $(random_seq 256 512); do
		printf '%s\t%s\n' "$(random_alpha)$(random_alnum)" "$(fake_token "$level")"
	done
} | shuf > "$file"
task "The token is in the line which $(bold starts with numbers) in file '$(bold "$file")'"
)
