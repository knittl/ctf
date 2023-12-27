#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task
(
rot="$(random_int 3 23)"
file="caesar-$(random_filename)-$rot.txt"
word="$rot$(random_alpha "$(random_int 8 16)" | to_lower)"
alphabet=abcdefghijklmnopqrstuvwxyz
rotate() { printf '%s%s\n' "$(input "$2" | cut -c"$(($1+1))-")" "$(input "$2" | cut -c"-$1")"; }
{
	echo "hello $STUDENT,"
	echo
	echo 'you have recovered the secret message!'
	echo "here is the word for your personal token: $word"
} | tr 'a-z' "$(rotate "$rot" "$alphabet")" > "$file"

token_format "$level" "$(mac64 "$word")" | while parse_token; do
	task "You received an encrypted file '$file'. Can you recover its plaintext? (Hint: $(bold tr), Caesar cipher). Get the token by running: $(bold check printf $level $mac) $(underlined "'last word of plaintext'")"
done
)
