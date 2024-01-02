#!/bin/sh

. ./lib.sh

if [ "$#" -lt 1 ]; then
	err "Usage: $0 build|push [FILE]..."
	exit 1
fi

mode="$1"; shift

cat "$@" | while read -r course student secret name; do
	test "$course" || continue
	test "$secret" || continue
	test "$student" || continue
	test "${course#'#'}" = "$course" || continue # skip comments

	img="knittl/$(input "$course" | to_lower):$student"

	case "$mode" in
		build)
			info "Building $course for '$student' with secret '$secret' ..."
			docker build \
				--build-arg=course="$course" \
				--build-arg=pepper="$secret" \
				--build-arg=student="$student" \
				--build-arg=studentname="$name" \
				-t "$img" .
			info "Build complete. Secret='$secret', Checksum: $(printf '%s' "$secret" | sha256sum | cut -c-64)"
			;;
		push)
			info "Pushing $img ..."
			docker push "$img"
			;;
	esac
done
