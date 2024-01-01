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
ARG pepper
ARG student
ARG studentname
RUN : "${course:?must be set} ${student:?must be set}"
ENV COURSE=$course
ENV TOKEN_PEPPER=$pepper
ENV STUDENT=$student
ENV STUDENTNAME=${studentname:-$student}

# TODO write and copy single script to generate tasks, then execute script

# TODO "global" README

RUN ./generate.sh 0 ./cd.sh /ctf/tasks/0-cd
RUN ./generate.sh 1 ./randomize_dirs.sh /ctf/tasks/1-files
RUN ./generate.sh 2 ./cat_simple.sh /ctf/tasks/2-cat
RUN ./generate.sh 3 ./ls_simple.sh /ctf/tasks/3-ls
RUN ./generate.sh 4 ./find_simple.sh /ctf/tasks/4-find
RUN ./generate.sh 5 ./text_simple.sh /ctf/tasks/5-text
RUN ./generate.sh 6 ./chmod_simple.sh /ctf/tasks/6-chmod
RUN ./generate.sh 7 ./crypto.sh /ctf/tasks/7-crypto
RUN ./generate.sh 8 ./regex.sh /ctf/tasks/8-regex
RUN ./generate.sh 9 ./pizza.sh /ctf/tasks/9-pizza
RUN ./generate.sh 10 ./scripting.sh /ctf/tasks/10-scripting

RUN ./motd.sh > /ctf/README

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

COPY --from=build /ctf/tasks /ctf/README ./

USER "$STUDENT"

# TODO different users for different "levels"
