#FROM scratch

#LABEL maintainer="ryan.hung"

#COPY root/ /
## Buildstage ##
FROM ghcr.io/linuxserver/baseimage-alpine:3.12 as buildstage

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
	curl && \
 echo "**** grab rclone ****" && \
 mkdir -p /root-layer && \
 curl -o \
	/root-layer/rclone.deb -L \
	"https://downloads.rclone.org/v1.47.0/rclone-v1.47.0-linux-amd64.deb"

# copy local files
COPY root/ /root-layer/

## Single layer deployed image ##
FROM scratch

LABEL maintainer="ryan.hung"

## python env
ENV MAIN_DIR=/home/coder

RUN mkdir -p "${MAIN_DIR}"

WORKDIR "${MAIN_DIR}"

RUN apt-get update && apt-get install -y \
    curl wget vim \
    python3 python3-dev gcc \
    gfortran musl-dev g++ \
    libffi-dev openssl-dev \
    libxml2 libxml2-dev \
    libxslt libxslt-dev \
    libjpeg-turbo-dev zlib-dev \
    libpq postgresql-dev \
    py3-pip

COPY requirements.txt "${MAIN_DIR}"

RUN pip3 install --upgrade cython \
    && pip3 install --upgrade pip \
    && pip3 install -r requirements.txt
# python env end

# Add files from buildstage
COPY --from=buildstage /root-layer/ /
