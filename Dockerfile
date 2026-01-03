### File: Dockerfile
##
## MozJPEG用のDockerイメージを組み立てる。
##
## Usage:
##
## ------ Text ------
## docker buildx build -f Dockerfile
## ------------------
##
## Build arg:
##
##   BASE_IMAGE - ベースとするイメージ名。
##   REVISION - MozJPEGのバージョン。
##
## Metadata:
##
##   id - c5f4ba13-b1c6-46a8-b3dd-d313834724cc
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   created - 2025-12-31
##   modified - 2026-01-03
##   copyright - Copyright (C) 2025-2026 qq542vev. All rights reserved.
##   license - <GPL-3.0-only at https://www.gnu.org/licenses/gpl-3.0.txt>
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/build-mozjpeg>
##   * <Bag report at https://github.com/qq542vev/build-mozjpeg/issues>

ARG BASE_IMAGE="gcr.io/distroless/base-nossl-debian12"

FROM debian:12-slim AS downloader

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=UTC0 DEBIAN_FRONTEND=noninteractive

WORKDIR /work

RUN \
	apt-get update && \
	apt-get install -y --no-install-recommends bzip2 && \
	apt-get download zlib1g libpng16-16 && \
	for deb in *.deb; do dpkg-deb -x "${deb}" rootfs; done && \
	rm -rf *.deb /var/lib/apt/lists/* rootfs/usr/share

ARG REVISION="v4.1.5"
ARG TARGETARCH
ARG TARGETVARIANT

COPY "build/${REVISION}/${TARGETARCH}/${TARGETVARIANT}"/*.gz "build/${REVISION}/${TARGETARCH}/${TARGETVARIANT}/"*.bz2 .

RUN \
	tar -C rootfs -xavf *mozjpeg* && \
	find rootfs/opt/*mozjpeg*/* \
		! -name 'bin' ! -name 'lib*' -type d \
		-exec rm -rf '{}' + && \
	find rootfs/opt/*mozjpeg*/* \
		'(' -name '*.a' -o -name '*.la' ')' -type f \
		-exec rm -rf '{}' +

FROM "${BASE_IMAGE}"

ARG BASE_IMAGE=gcr.io/distroless/base-nossl-debian12

LABEL org.opencontainers.image.base.name="${BASE_IMAGE}"

ENV PATH="/opt/mozjpeg/bin:/opt/libmozjpeg/bin"
ENV LD_LIBRARY_PATH="/opt/mozjpeg/lib32:/opt/mozjpeg/lib64:/opt/libmozjpeg/lib32:/opt/libmozjpeg/lib64"

COPY --from=downloader /work/rootfs /
