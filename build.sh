#!/bin/sh

. ./lib.sh

if [ "$#" -lt 1 ]; then
	err "Usage: $0 build|push [FILE]..."
fi

mode="$1"; shift

cat "$@" | while read -r course student secret; do
	test "$course" || continue
	test "$student" || continue
	test "$secret" || continue
	test "${course#'#'}" = "$course" || continue # skip comments
	case "$mode" in
		build)
			info "Building $course for '$student' with secret '$secret' ..."
			docker build --build-arg=course="$course" --build-arg=student="$student" --build-arg=pepper="$secret" -t "knittl/ctf:$student" .
			;;
		push)
			img="knittl/ctf:$student"
			info "Pushing $img ..."
			docker push "$img"
			;;
	esac
done
