#!/bin/sh

. ./lib.sh >/dev/null

# TODO only write check-tokens hint when "tutormode" is enabled

token0="$(token 0-0)"
faketoken0="$(fake_token 0-0)"
cat <<EOF
Welcome $(bold "${STUDENTNAME:-$STUDENT}"), these are your personal tasks!

Your goal is to find tokens, such as $(bold "$token0").
Tokens comprise the task number, your student id, and two special values.

Not all tokens are valid. For instance, $(bold "$faketoken0")
is an invalid token.

You can verify tokens by running $(bold check-token). Try it out:

    \$ $(bold check-token "$token0")
    \$ $(bold check-token "$faketoken0")

Start by changing into $(bold "~/$(cd tasks && echo 00-*/)") and then type $(bold show-tasks).
Press $(bold q) to quit the task list and to return to the shell prompt.

You can always type $(bold show-motd) to see this message again.

$(fmt dim "Timestamp: $(date -u +%FT%TZ)")
$(fmt dim "Checksum:  $(printf '%s' "$TOKEN_PEPPER" | sha256sum | cut -c-64)")

EOF

# TODO checksum should change if container is regenerated (???)

