#!/bin/sh

level="$1"
generator="$2"
dir="$3"

current_level="$level" "$generator" "$dir" && cat "$dir/README"
