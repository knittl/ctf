FROM ubuntu:24.04 AS base

ENV LANG=C.UTF-8

RUN apt update \
	&& apt install -y xxd \
	&& apt install -y man-db netbase less nano \
	&& apt install -y psmisc \
	&& apt install -y curl \
	&& apt install -y sudo \
	&& apt install -y git \
	&& apt install -y unminimize \
	&& yes|unminimize \
	&& rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

COPY bin/mac64 /usr/local/bin/

# ----------

FROM base AS build

WORKDIR /ctf
COPY *.sh tasks/ /ctf/

ARG course=BIT
ARG pepper
ARG student
ARG studentname
RUN : "${course:?must be set} ${student:?must be set} ${pepper:?must be set}"
ENV COURSE=$course
ENV TOKEN_PEPPER=$pepper
ENV STUDENT=$student
ENV STUDENTNAME=${studentname:-$student}

# TODO write and copy single script to generate tasks, then execute script

# TODO "global" README

RUN ./generate.sh 0 ./level-00.sh /ctf/tasks/00-intro
RUN ./generate.sh 1 ./level-01.sh /ctf/tasks/01-re-crypto
RUN ./generate.sh 2 ./level-02.sh /ctf/tasks/02-permissions
RUN ./generate.sh 3 ./level-03.sh /ctf/tasks/03-text
RUN ./generate.sh 4 ./level-04.sh /ctf/tasks/04-find
RUN ./generate.sh 5 ./level-05.sh /ctf/tasks/05-scripts

RUN ./motd.sh > /ctf/README

# ---------------

FROM base
LABEL org.opencontainers.image.authors="p23687@fh-hagenberg.at" \
	org.opencontainers.image.description="CTF-like exercises"
	# org.opencontainers.image.source="https://github.com/knittl/hyp1-docker" \
	# org.opencontainers.image.url="https://github.com/knittl/hyp1-docker"


ENV SHELL=/bin/bash

COPY show-tasks show-motd bin/* \
	/usr/local/bin/

ARG course=BIT
ARG student
ARG studentname
ENV COURSE=$course
ENV STUDENT=$student
ENV STUDENTNAME=${studentname:-$student}

RUN useradd -ms /bin/bash --no-log-init -c "Account for $STUDENTNAME ($STUDENT)" -G sudo "$STUDENT" \
	&& printf '%s:%s\n' "$STUDENT" "$(tr -cd '[:lower:][:digit:]' </dev/urandom | dd bs=1 count=8 | { cat; echo; } | tee "/home/$STUDENT/.password")" | chpasswd \
	&& chmod a= "/home/$STUDENT/.password" \
	&& chown "$STUDENT" "/home/$STUDENT/.password" \
	&& touch "/home/$STUDENT/.sudo_as_admin_successful" \
	&& sed -i '/^#force_color_prompt=yes$/s/^#//' "/home/$STUDENT/.bashrc" \
	&& echo 'show-motd' >> "/home/$STUDENT/.bashrc"
WORKDIR "/home/$STUDENT"

COPY --from=build --chown="$STUDENT:$STUDENT" /ctf/tasks /ctf/README ./
COPY --from=build --chown="$STUDENT:$STUDENT" /tmp/ctf/checks/* /usr/local/bin/

USER "$STUDENT"

# TODO different users for different "levels"
