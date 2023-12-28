#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task
(
rot="$(random_int 3 23)"
file="CAESAR-$(random_filename)-$rot.TXT"
alphabet=ABCDEFGHIJKLMNOPQRSTUVWXYZ
rotate() { printf '%s%s\n' "$(input "$2" | cut -c"$(($1+1))-")" "$(input "$2" | cut -c"-$1")"; }
cat <<EOF | tr 'A-Z' "$(rotate "$rot" "$alphabet")" > "$file"
HELLO $(input "$STUDENT" | to_upper),

YOU HAVE RECOVERED THE SECRET MESSAGE!

DON'T BE CONFUSED BY THESE FAKE TOKENS: $(fake_token "$level") $(fake_token "$level")
OR THIS ONE: $(fake_token "$level")

HERE IS YOUR PERSONAL TOKEN: $(current_token)

YOU CAN IGNORE ALL FOLLOWING TOKENS:
$(fake_token "$level") $(fake_token "$level") $(fake_token "$level")
$(fake_token "$level")
$(fake_token "$level") $(fake_token "$level")
EOF

task "You received an encrypted file '$file'. Can you recover its plaintext? (Hint: $(bold tr), Caesar cipher)."
)
