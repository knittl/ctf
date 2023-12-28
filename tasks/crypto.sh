#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task
(
rot="$(random_int 3 23)"
file="caesar-$(random_filename)-$rot.txt"
alphabet=ABCDEFGHIJKLMNOPQRSTUVWXYZ
rotate() { printf '%s%s\n' "$(input "$2" | cut -c"$(($1+1))-")" "$(input "$2" | cut -c"-$1")"; }
{
	echo "HELLO $STUDENT,"
	echo
	echo 'YOU HAVE RECOVERED THE SECRET MESSAGE!'
	echo "HERE IS YOUR PERSONAL TOKEN: $(current_token)"
} | tr 'A-Z' "$(rotate "$rot" "$alphabet")" > "$file"

task "You received an encrypted file '$file'. Can you recover its plaintext? (Hint: $(bold tr), Caesar cipher)."
)
