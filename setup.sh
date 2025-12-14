#!/bin/sh

. ./lib.sh

# export COURSE="$course"
# export STUDENT="$student"
export TOKEN_PEPPER="${TOKEN_PEPPER:-$(random_alnum)}"

echo "Setup done: $COURSE $STUDENT $TOKEN_PEPPER"
