#!/bin/sh

. ./lib.sh

: "${current_level:?must be set}"

init_root "$1"

exec 2> README

## custom delimiter
next_task
user="$(random_alnum)"
cat <<EOF > passwd
CTF-$user:x:1042:1042:$(token 1-1 | tr : ,):/tmp:/bin/false
EOF
task "Token is in comment field of user '$user' in file 'passwd'"

## text search
next_task
while include="$(random_alnum 4)" exclude="$(random_alnum 4)"; do
	test "$include" != "$exclude" && break
done

task "Token is in comment of usernames which contain '$include' but not '$exclude' in file 'passwd'"
i=1
current_token | tr ':' '\n' |
while read -r part; do
	print_passwd_entry() {
		name="$COURSE-$(random_alnum)${2:+-$2}"
		printf '%s:x:%d:%d:%s:/tmp:/bin/false\n' "$name" "$id" "$id" "$1"
	}

	id="$((1042+i))"
	: "$((i+=1))"
	print_passwd_entry "$part" "$include-$include"
	while chance 50; do
		id="$((1042+i))"
		: "$((i+=1))"
		print_passwd_entry "$(random_alnum)" "$include-$exclude"
	done
done >> passwd
