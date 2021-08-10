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
## python env
ENV MAIN_DIR=/home/coder

RUN mkdir -p "${MAIN_DIR}"

WORKDIR "${MAIN_DIR}"

RUN apk add --no-cache --update \
    python3-dev gcc \
    gfortran musl-dev g++ \
    libffi-dev openssl-dev \
    libxml2 libxml2-dev \
    libxslt libxslt-dev \
    libjpeg-turbo-dev zlib-dev \
    libpq postgresql-dev \

COPY requirements.txt "${MAIN_DIR}"

RUN pip install --upgrade cython \
    && pip install --upgrade pip \
    && pip install -r requirements.txt
# python env end
# Add files from buildstage
COPY --from=buildstage /root-layer/ /
