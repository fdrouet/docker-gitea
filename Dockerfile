FROM alpine:3.11
LABEL maintainer="Frédéric Drouet <dev@drouet.me>"

# inspired from :
#  - https://github.com/go-gitea/gitea/blob/v1.11.4/Dockerfile
#  - https://github.com/watson81/docker-gitea-rpi/commits/master/Dockerfile

# Gitea release version
ARG VERSION=1.11.4
# Gitea release linux architecture (386 / amd64 / arm-5 / arm-6 / arm64)
ARG EDITION=amd64
ARG USER_UID=500
ARG USER_GID=500

ENV GITEA_WORK_DIR /data/gitea
ENV GITEA_CUSTOM /data/gitea
ENV USER git
ENV GODEBUG=netdns=go

## install needed packages
RUN apk --no-cache add \
      bash \
      ca-certificates \
      curl \
      gettext \
      git \
      linux-pam \
      openssh \
      sqlite \
      su-exec \
      tzdata

## install needed packages
RUN addgroup \
    -S -g $USER_GID \
    $USER \
  && adduser \
    -S -H -D \
    -h /data/git \
    -s /bin/bash \
    -u $USER_UID \
    -G $USER \
    $USER \
  && echo "git:$(dd if=/dev/urandom bs=24 count=1 status=none | base64)" | chpasswd

## 
RUN curl -fSL https://github.com/go-gitea/gitea/archive/v$VERSION.tar.gz | \
    tar xz gitea-$VERSION/docker --exclude=gitea-$VERSION/docker/Makefile --strip-components=3

## Get and install Gitea binary
RUN mkdir -p /app/gitea \
	&& curl -fSLo /app/gitea/gitea-$VERSION https://github.com/go-gitea/gitea/releases/download/v$VERSION/gitea-$VERSION-linux-$EDITION \
	&& chmod 0755 /app/gitea/gitea-$VERSION \
  && ln -s /app/gitea/gitea-$VERSION /app/gitea/gitea

EXPOSE 22 3000

# VOLUME ["/data"]
# CMD ["/app/gitea/gitea"]

ENTRYPOINT ["/usr/bin/entry.sh", "/usr/bin/entrypoint"]
CMD ["/bin/s6-svscan", "/etc/s6"]
