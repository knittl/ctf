#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

rand_dir() { find "$1" -type d | pick_random; }
rand_cd() { cd -- "$(rand_dir "$root")"; }

mkdirs() { repeat "${1:-2}" rand_mkdir; } >/dev/null
mkfiles() { repeat "${1:-4}" rand_touch; } >/dev/null

(
for _ in $(seq 8); do
	rand_cd
	mkdirs
	mkfiles
done
)

next_task # 1
(
rand_cd
mkdir "$(current_token)"
task "Navigate the directory tree with $(bold ls) to find the directory with token $level as name"
)

next_task # 2
(
rand_cd
touch -- ".$(current_token)"
task "Navigate the directory tree to find the $(bold hidden file) with token $level as name"
)

next_task # 3
(
rand_cd
mkdir ".$(current_token)"
task "Navigate the directory tree to find the $(bold hidden directory) with token $level as name"
)

next_task # 4
(
rand_cd
file="$(rand_touch "$(current_token)")" # TODO better file name?
prev="$level"
task "The token is the $(bold name) of a file in the directory tree"

next_task # 5
current_token > "$file"
task "The token is in the $(bold content) of the file from task $prev"
)
next_task # 5: need to re-apply increment from subshell to parent shell

next_task # 6
(
current_token > "-$(random_alnum)"
task "The token is in the $(bold content) of the file whose name $(bold starts with a hyphen)"
)

next_task # 7
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
task "Use a $(bold regular expression) to find the $(bold largest number) in file '$file' (NB the file contains $(bold positive) and $(bold negative integers)). Get the token by running: $(bold check printf $level $mac) $(underlined largest_number)"
done
)

next_task # 8
(
proto="$(pick_random tcp udp)"
awk -v proto="$proto" '!/^#/&&$0~proto' /etc/services | pick_random | while read -r service port _; do
	port="${port%/$proto}"
	token_format "$level" "$(mac64 "$port")" | while parse_token; do
		task "Which $(bold "$(echo "$proto" | to_upper) port") is associated with the service/protocol '$service'? The file $(bold "'/etc/services'") contains a list of services and their assigned ports. Get the token by running: $(bold check printf $level $mac) $(underlined port_number)"
	done
done
)

next_task # 9
(
proto="$(pick_random tcp udp)"
awk -v proto="$proto" '!/^#/&&$0~proto' /etc/services | pick_random | while read -r service port _; do
	port="${port%/$proto}"
	token_format "$level" "$(mac64 "$service")" | while parse_token; do
		task "Which $(bold service/protocol) is associated with $(echo "$proto" | to_upper) port $port? The file $(bold "'/etc/services'") contains a list of services and their assigned ports. Get the token by running: $(bold check printf $level $mac) $(underlined service_name)"
	done
done
)

next_task # 10
(
rot="$(random_int 3 23)"
file="CAESAR-$(random_filename)-$rot.TXT"
alphabet=ABCDEFGHIJKLMNOPQRSTUVWXYZ
rot() { printf '%s%s\n' "$(input "$2" | cut -c"$(($1+1))-")" "$(input "$2" | cut -c"-$1")"; }
rotate() { tr "$1" "$(rot "$2" "$1")"; }

fake_tokens() { repeat "$(random_int 2 8)" current_fake_token | join_lines ' '; }

rotate "$alphabet" "$rot" > "$file" <<EOF
HELLO $(input "${STUDENTNAME:-$STUDENT}" | to_upper),

YOU HAVE RECOVERED THE SECRET MESSAGE!
ONLY UPPERCASE LETTERS ARE ROTATED, YOU MUST KEEP ALL LOWERCASE LETTERS FROM THE CIPHERTEXT.
(RANDOM NOISE: $(input 'if you can read this, you are rotating lowercase letters!' | rotate "$(input "$alphabet" | to_lower)" "$rot"))

DON'T BE CONFUSED BY THESE FAKE TOKENS: $(fake_tokens)
OR THIS ONE: $(fake_token "$level")

HERE IS YOUR PERSONAL TOKEN: $(current_token)

YOU CAN IGNORE ALL FOLLOWING TOKENS:
$(repeat "$(random_int 4 16)" fake_tokens)
EOF

task "You received an encrypted file '$file'. Can you recover its plaintext? (Hint: $(bold tr), Caesar cipher)."
)
