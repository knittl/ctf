#!/bin/sh

awk -F'\t' '
/^#/ { print; next }
{
	split($1, names, /[, ]*/);
	split($3, ids, "@");

	print ids[1] "\t" names[2];
}
' "$@"
