FROM ubuntu:23.10 AS base

ENV LANG=C.UTF-8

RUN yes|unminimize
RUN apt update \
	&& apt install -y xxd \
	&& apt install -y man-db netbase less nano \
	&& apt install -y psmisc \
	&& apt install -y curl \
	&& apt install -y sudo \
	&& apt install -y git \
	&& rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

COPY bin/mac64 /usr/local/bin/

# ----------

FROM base AS build

WORKDIR /ctf
COPY *.sh tasks/ /ctf/

ARG course=CTF
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
	&& current_level=1 ./cat_simple.sh /ctf/tasks/1-cat \
	&& cat /ctf/tasks/1-cat/README \
	&& echo done

COPY README /ctf
RUN awk -v student="$STUDENT" '{gsub("\\${STUDENT}", student);print}' /ctf/README > /ctf/README.tmp && printf 'Checksum: %s\n\n' "$(printf '%s' "$TOKEN_PEPPER" | sha256sum | cut -c-64)" >> /ctf/README.tmp

# TODO copy scripts
# TODO generate tasks

# ---------------

FROM base
LABEL org.opencontainers.image.authors="p23687@fh-hagenberg.at" \
	org.opencontainers.image.description="CTF-like exercises"
	# org.opencontainers.image.source="https://github.com/knittl/ctf" \
	# org.opencontainers.image.url="https://github.com/knittl/ctf"


ENV SHELL=/bin/bash

COPY bin/. /usr/local/bin/

ARG course=CTF
ARG student
ARG studentname
ENV COURSE=$course
ENV STUDENT=$student
ENV STUDENTNAME=${studentname:-$student}

RUN useradd -ms /bin/bash --no-log-init -c 'Account for '"$STUDENT" "$STUDENT" \
	&& sed -i '/^#force_color_prompt=yes$/s/^#//' "/home/$STUDENT/.bashrc" \
	&& echo 'show-motd' >> "/home/$STUDENT/.bashrc"
WORKDIR "/home/$STUDENT"

COPY --from=build /ctf/tasks .
COPY --from=build /ctf/README.tmp README

USER "$STUDENT"

# TODO different users for different "levels"
