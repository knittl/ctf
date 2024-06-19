#!/bin/sh

. ./lib.sh >/dev/null

cat <<EOF
Welcome $(bold "${STUDENTNAME:-$STUDENT}"), these are your personal tasks!

Your goal is to find tokens, such as $(bold "$(token 0-0)").
Tokens comprise the task number, your student id, and two special values.

Not all tokens are valid. For instance, $(bold "$(fake_token 0-0)") is an
invalid token.

Start by changing into $(bold "~/$(cd tasks && echo 00-*/)") and then typing $(bold show-tasks).
Press $(bold q) to quit the task list and to return to the shell prompt.

You can always type $(bold show-motd) to see this message again.

$(fmt dim "Checksum: $(printf '%s' "$TOKEN_PEPPER" | sha256sum | cut -c-64)")

EOF
