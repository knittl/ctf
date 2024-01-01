#!/bin/sh

. ./lib.sh >/dev/null

cat <<EOF
Welcome $(bold "${STUDENTNAME:-$STUDENT}"), these are your personal challenges!

Your goal is to find tokens, such as $(bold "$(token 0-0)").
Tokens comprise the task number, your student id, and two special values.

Start by changing into $(bold '~/1-files/') and then typing $(bold show-tasks).

You can always type $(bold show-motd) to see this message again.

$(fmt dim)Checksum: $(printf '%s' "$TOKEN_PEPPER" | sha256sum | cut -c-64)$(fmt reset)

EOF
