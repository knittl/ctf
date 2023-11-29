#!/bin/sh

. ./lib.sh

assert_equal() {
	expected="$1"
	actual="$2"
	test "$expected" = "$actual" || fail '%s != %s\n' "$expected" "$actual"
}

assert_not_equal() {
	expected="$1"
	actual="$2"
	test "$expected" != "$actual" || fail '%s = %s\n' "$expected" "$actual"
}

fail() {
	format="$1"
	shift
	printf "FAIL: $format\n" "$@"
	return 1
}

COURSE=TEST
STUDENT=id123
TOKEN_PEPPER=pepper

set -e

# must generate correct (predetermined) token
(
	assert_equal 'TEST{42:id123:31337:4IOMFDEK}' "$(token 42 TEST id123 pepper 31337)"
)

# must generate random nonce and distinct tokens
(
	assert_not_equal "$(token 42 TEST id123 pepper)" "$(token 42 TEST id123 pepper)"
)

# must generate token for current level
(
	current_level=4
	init_level
	next_task
	next_task
	case "$(current_token)" in
		TEST{4-2:id123:*:*}) true ;;
		*) fail 'Current token does not contain level/task' ;;
	esac
)

# can validate single token
(
	verify_token "$(token 1)" || fail 'Could not verify token'
)

# detects single fake token
(
	! verify_token "$(fake_token 1)" || fail 'Did not reject fake token'
)

# extracts embedded tokens
(
	# constant nonce and MAC for testing:
	random_alnum() { echo NONCE; }
	random_base32() { echo FAKEMAC; }

	actual=$(extract_tokens <<-EOF
	foo$(token 1)$(token 2)bar
	$(fake_token 3)$(token 4)
	EOF
	)

	expected=$(cat <<-EOF
	TEST{1:id123:NONCE:WKNLIDOG}
	TEST{2:id123:NONCE:K2XSI334}
	TEST{3:id123:NONCE:FAKEMAC}
	TEST{4:id123:NONCE:MC2UMBSU}
	EOF
	)

	assert_equal "$expected" "$actual"
)

# validates multiple tokens
(
	{
		token 1
		token 2
		token 3
	} | verify_tokens >/dev/null || fail 'Could not verify tokens'
)

# fails when at least one token is invalid
(
	! {
		token 1
		fake_token 2
		token 3
	} | verify_tokens >/dev/null || fail 'Did not reject fake token'
)
