FROM ubuntu:23.10 AS build

RUN apt-get update && apt-get install -y xxd

RUN mkdir -p /ctf/tasks
WORKDIR /ctf
COPY *.sh random /ctf/

ARG course=BIT
ARG student
ARG pepper
RUN : "${course:?must be set} ${student:?must be set}"
ENV COURSE=$course
ENV STUDENT=$student
ENV TOKEN_PEPPER=$pepper

# TODO write and copy single script to generate tasks, then execute script

# TODO "global" README

RUN . ./lib.sh \
	&& . ./setup.sh \
	&& ./cat_simple.sh /ctf/tasks/1-cat \
	&& cat /ctf/tasks/1-cat/README  \
	&& echo done

COPY README /ctf
RUN awk -v student="$STUDENT" '{gsub("\\${STUDENT}", student);print}' /ctf/README > /ctf/README.tmp

# TODO copy scripts
# TODO generate tasks

FROM ubuntu:23.10

ARG student
ENV STUDENT=$student

WORKDIR /home/ubuntu

COPY --from=build /ctf/tasks .
COPY --from=build /ctf/README.tmp README
COPY dot.profile .profile

USER ubuntu

ENTRYPOINT [ "/bin/bash" ]
CMD [ "-l" ]

# TODO user account
# TODO unminimize / man pages
# TODO different users for different "levels"

# TODO export course/student to env?
# TODO home directory for $student

# TODO hash pepper to "verify" correct "build"

# TODO install binaries: nano, man, less, …
# TODO setup colors
