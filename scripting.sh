#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task
(
word="$(random_alnum)"
token_format "$level" "$(mac64 "hello $word")" | while parse_token; do
	task "Create an executable script file which writes $(bold "'hello $word'") (without quotes) to standard output. Get the token by running: $(bold "check hello $level $mac") $(underlined ./your_script)"
done
)
