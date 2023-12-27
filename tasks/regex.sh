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

next_task
(
awk '!/^#/&&/tcp/' /etc/services | pick_random | while read -r service port _; do
	port="${port%/tcp}"
	token_format "$level" "$(mac64 "$port")" | while parse_token; do
		task "Which TCP port is associated with the service/protocol '$service'? The file '/etc/services' contains a list of services and their assigned ports. Get the token by running: $(bold check printf $level $mac) $(underlined port_number)"
	done
done
)

next_task
(
awk '!/^#/&&/tcp/' /etc/services | pick_random | while read -r service port _; do
	port="${port%/tcp}"
	token_format "$level" "$(mac64 "$service")" | while parse_token; do
		task "Which service/protocol is associated with TCP port $port? The file '/etc/services' contains a list of services and their assigned ports. Get the token by running: $(bold check printf $level $mac) $(underlined service_name)"
	done
done
)
