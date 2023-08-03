#!/bin/sh

. ./lib.sh

root="$1"

test -d "$root" || mkdir -p "$root"

cd "$root"
root="$PWD" # get absolute path

rand_dir() { find "$1" -type d | pick_random; }
rand_cd() { cd "$(rand_dir "$root")"; }

fake_pepper='invalid' # export? # TODO randomize?
info "Fake token pepper: $fake_pepper" >&2
fake_token() ( # run in subshell
	export TOKEN_PEPPER="$fake_pepper"
	token "$1"
)

## head
file="$(rand_touch)"
echo
task "Token in first line of '$file'"
{
	lines="$(random_int 64 256)"
	token 1-1
	random_alnum "$((lines*80))" | fold -w64
} > "$file"

## simple file:
file="$(rand_touch)"
echo

lines="$(random_int 64 256)"
line="$(random_int 64 "$lines")"
line="$(random_int 2 8)" # TODO first line, one of first few lines?

## head + cut with default delim (tab)
for i in $(seq "$lines"); do
	columns="$(random_int 4 16)"
	column="$(random_int 4 "$columns")"
	for j in $(seq "$columns"); do
		if test "$i" -eq "$line" && test "$j" -eq "$column"; then
			task "Token in line $line, col $column in file '$file'" >&2
			token 1-1
		else
			# TODO add other text too?
			fake_token 1-1
		fi
	done | paste -sd '\t'
done > "$file"
# TODO this setup very expensive

## cut with custom delim (fake passwd :)
user="$(random_alnum)"
cat <<EOF > passwd
BIT-$user:x:1042:1042:$(token 1-1 | tr : ,):/tmp:/bin/false
EOF
echo
task "Token in comment field of user '$user' in passwd"

## cut + grep
while include="$(random_alnum 4)" exclude="$(random_alnum 4)"; do
	test "$include" != "$exclude" && break
done

echo
task "Token in comment of usernames which contain '$include' but not '$exclude' in passwd"

i=1
token 1-1 | tr ':' '\n' |
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

## sort (+tail)
file="$(rand_touch)"
echo
task "Token in line with largest number in '$file'"
{
	for i in $(random_seq 1024 2048); do fake_token 1-1; done
	token 1-1
} | nl | shuf > "$file"

## sort | uniq
file="$(rand_touch)"
echo
task "Token is line with highest frequency in '$file'"
freq="$(random_int 16)"
{
	for _ in $(random_seq 256 512); do
		token="$(fake_token 1-1)"
		for _ in $(random_seq "$freq"); do
			echo "$token"
		done
	done

	token="$(token 1-1)"
	for _ in $(random_seq "$((freq+1))" "$((freq*2))"); do
		echo "$token"
	done
} | shuf > "$file"


## grep
file="$(rand_touch)"
tag="$(random_alnum)"
echo
task "Token is in line which starts with '$tag' in '$file'"
{
	printf '%s\t%s\t%s\n' "$tag" "$(token 1-1)" "$(random_alnum)"
	for _ in $(random_seq 512 1024); do
		printf '%s\t%s\t%s\n' "$(random_alnum)" "$(fake_token 1-1)" "$tag"
	done
} | shuf > "$file"


## grep | grep or grep with regex
file="$(rand_touch)"
start="$(random_alnum)"
end="$(random_alnum)"
echo
task "Token is in line which starts with '$start' and ends with '$end' in '$file'"
{
	line() { printf '%s\t%s\t%s\n' "$1" "$2" "$3"; }
	line "$start" "$(token 1-1)" "$end"
	for _ in $(random_seq 512 1024); do
		case "$(random_int 5)" in
			1) line "$start" "$(fake_token 1-1)" "$(random_alnum)" ;;
			2) line "$(random_alnum)" "$(fake_token 1-1)" "$end" ;;
			3) line "$(random_alnum)" "$(fake_token 1-1)" "$start" ;;
			4) line "$end" "$(fake_token 1-1)" "$(random_alnum)" ;;
			5) line "$(random_alnum)" "$(fake_token 1-1)" "$(random_alnum)" ;;
		esac
	done
} | shuf > "$file"


## grep | grep -v
file="$(rand_touch)"
start="$(random_alnum)"
end="$(random_alnum)"
echo
task "Token is in line which starts with '$start' but does not end with '$end' in file '$file'"
{
	line() { printf '%s\t%s\t%s\n' "$1" "$2" "$3"; }
	line "$start" "$(token 1-1)" "$(random_alnum)"
	for _ in $(random_seq 512 1024); do
		case "$(random_int 5)" in
			1) line "$start" "$(fake_token 1-1)" "$end" ;;
			2) line "$(random_alnum)" "$(fake_token 1-1)" "$end" ;;
			3) line "$(random_alnum)" "$(fake_token 1-1)" "$start" ;;
			4) line "$end" "$(fake_token 1-1)" "$(random_alnum)" ;;
			5) line "$(random_alnum)" "$(fake_token 1-1)" "$(random_alnum)" ;;
		esac
	done
} | shuf > "$file"


## grep -v
file="$(rand_touch)"
tag="$(random_alnum)"
echo
task "Token is in line which does not contain '$tag' in '$file'"
{
	printf '%s %s\n' "$(random_alnum)" "$(token 1-1)"
	for _ in $(random_seq 512 1024); do
		printf '%s %s\n' "$tag" "$(fake_token 1-1)"
	done
} | shuf > "$file"

## grep -i
file="$(rand_touch)"
until tag="$(random_alnum | grep '[a-z]' | grep '[A-Z]')"; do :; done
echo
task "Token is in line which contains '$(printf '%s' "$tag"|to_lower)' in mixed case in '$file'"
{
	printf '%s\t%s\n' "$(random_alnum)$tag$(random_alnum)" "$(token 1-1)"
	for _ in $(random_seq 512 1024); do
		printf '%s\t%s\n' "$(random_alnum)$(random_alnum)$(random_alnum)" "$(fake_token 1-1)"
	done
} | shuf > "$file"

## grep numbers
file="$(rand_touch)"
echo
task "Token is in line which starts with numbers in '$file'"
{
	printf '%s\t%s\n' "$(random_digits)$(random_alnum)" "$(token 1-1)"
	for _ in $(random_seq 512 1024); do
		printf '%s\t%s\n' "$(random_alpha)$(random_alnum)" "$(fake_token 1-1)"
	done
} | shuf > "$file"

# TODO grep -r
# TODO grep -o e.g. "find the token. format = xyz"
