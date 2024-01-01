#!/bin/sh

. ./lib.sh

if [ "$#" -lt 1 ]; then
	err "Usage: $0 build|push [FILE]..."
fi

mode="$1"; shift

cat "$@" | while read -r course secret student name; do
	test "$course" || continue
	test "$secret" || continue
	test "$student" || continue
	test "${course#'#'}" = "$course" || continue # skip comments
	case "$mode" in
		build)
			info "Building $course for '$student' with secret '$secret' ..."
			docker build \
				--build-arg=course="$course" \
				--build-arg=pepper="$secret" \
				--build-arg=student="$student" \
				--build-arg=studentname="$name" \
				-t "knittl/ctf:$student" .
			;;
		push)
			img="knittl/ctf:$student"
			info "Pushing $img ..."
			docker push "$img"
			;;
	esac
done
