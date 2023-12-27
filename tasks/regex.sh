#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task
(
file="$(rand_touch)"
pos() {
	num="$(random_int 16384)"
	printf '%s ' "$num"
	if [ "${largest_number:-$num}" -le "$num" ]; then largest_number="$num"; fi
}
neg() {
	num="-$(random_int 8192 32768)"
	printf '%s ' "$num"
}
word() { printf '%s ' "$(random_alpha "$(random_int 8 16)")"; }
for _ in $(random_seq 256 512); do
	"$(pick_random pos pos pos neg neg word)"
	if chance 10; then echo; fi
done > "$file"

token_format "$level" "$(mac64 "$largest_number")" | while parse_token; do
	task "Use a regular expression to find the largest number in file '$file' (NB the file contains negative numbers). Get the token by running: $(bold check printf $level $mac) $(underlined largest_number)"
done
)
