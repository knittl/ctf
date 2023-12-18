#!/bin/sh

level="$1"
generator="$2"
root="$3"

. ./setup.sh &&
	current_level="$level" "$generator" "$root" &&
	cat "$root/README"

