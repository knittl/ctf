#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task
(
word="$(random_alnum)"
token_format "$level" "$(mac64 "hello $word")" | while parse_token; do
	task "Create an executable script file which writes $(bold "'hello $word'") (without quotes) to standard output. Get the token by running: $(bold "check hello $level $mac 1") $(underlined ./your_script)"
done
)

next_task
(
word() { random_alnum; }
word1="$(word)"
word2="$(word)  $(word)"
token_format "$level" "$(printf 'hello %s\nhello %s\n' "$word1" "$word2" | mac64)" | while parse_token; do
task "Create an executable script file which writes $(underlined "'hello XXXX'") (without quotes) to standard output ($(underlined XXXX) shall be the first argument passed to the script). The script must print arguments with spaces verbatim (i.e. ./script 'a  b' outputs 'hello a  b'). Get the token by running: $(bold "check hello $level $mac 2") $(underlined ./your_script "'$word1'" "'$(word)'" "'$word2'" "'$(word)'")"
done
)
