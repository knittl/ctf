#!/bin/sh

. ./lib.sh

: "${current_level:?must be set}"

root="$1"
test -d "$root" || mkdir -p "$root"
cd "$root"
root="$PWD" # get absolute path

# TODO create readme
exec 2> README

## simple file:
next_task
cd "$(rand_mkdir)"
touch "$(current_token)"
cd ..
task 'Token is a file in a random directory'

next_task
mkdir -p lst
cd lst
current_token | while parse_token; do
	year="$(random_int 10 20)"

	# touch -t "${year}01$(random_int 31)$(rand_hour)$(rand_minute)" "$course"
	# touch -t "${year}02$(random_int 28)$(rand_hour)$(rand_minute)"  '{'
	# touch -t "${year}03$(random_int 31)$(rand_hour)$(rand_minute)"  "$exercise"
	# touch -t "${year}04$(random_int 30)$(rand_hour)$(rand_minute)"  ':'
	# touch -t "${year}05$(random_int 31)$(rand_hour)$(rand_minute)"  "$student"
	# touch -t "${year}06$(random_int 30)$(rand_hour)$(rand_minute)"  ':'
	# touch -t "${year}07$(random_int 31)$(rand_hour)$(rand_minute)"  "$nonce"
	# touch -t "${year}08$(random_int 31)$(rand_hour)$(rand_minute)"  ':'
	# touch -t "${year}09$(random_int 30)$(rand_hour)$(rand_minute)"  "$mac"
	# touch -t "${year}10$(random_int 31)$(rand_hour)$(rand_minute)"  '}'

	touch -d "1 years ago 1 month ago 1 week ago 1 day ago" "$course"
	touch -d "2 years ago 2 month ago 2 week ago 2 day ago" '{'
	touch -d "3 years ago 3 month ago 3 week ago 3 day ago" "$exercise"
	touch -d "4 years ago 4 month ago 4 week ago 4 day ago" ":$student:"
	touch -d "5 years ago 5 month ago 5 week ago 5 day ago" "$nonce"
	touch -d "6 years ago 6 month ago 6 week ago 6 day ago" ':'
	touch -d "7 years ago 7 month ago 7 week ago 7 day ago" "$mac"
	touch -d "8 years ago 8 month ago 8 week ago 8 day ago" '}'
done
task 'Token is all files sorted by modification date'

# TODO token in target of softlink
