#!/usr/bin/gmake -f

### Script: makefile
##
## ファイルを作成する。
##
## Metadata:
##
##   id - 12d86b83-9061-4112-8010-eab2952c051d
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.1.0
##   created - 2025-11-15
##   modified - 2025-12-25
##   copyright - Copyright (C) 2025-2025 qq542vev. All rights reserved.
##   license - <GPL-3.0-only at https://www.gnu.org/licenses/gpl-3.0.txt>
##   depends - docker, find, git, mv, sed
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/build-mozjpeg>
##   * <Bag report at https://github.com/qq542vev/build-mozjpeg/issues>

# Sp Targets
# ==========

.PHONY: all clean rebuild update publish unpublish image help version

.SILENT: help version

# Macro
# =====

VERSION = 1.0.0

BUILD = build
ARCHS = 386 386-simd amd64 amd64-simd arm/v7 arm/v7-simd arm64/v8 arm64/v8-simd ppc64le s390x
PARCHS != for arch in $(ARCHS); do echo "%/$${arch}"; done
UPSTREAM = https://github.com/mozilla/mozjpeg.git

DOCKER = eval docker buildx build --secret 'id=attach,src=attach.yaml' --build-arg MOZJPEG_TAG="$${tag}" --platform "linux/$${arch}" --progress plain -o - $${docker_opts-} $(DOCKER_OPTS) . | tar -xvC '$(@)'
FAIL = { \
	status="$${?}"; \
	rm -rf -- '$(@)'; \
	exit "$${status}"; \
}
BUILD_CMD = \
	trap ':' INT; \
	{ mkdir -p -- '$(@)' && $(DOCKER); } || $(FAIL)
SIMD = [ '$(@)' != '$(@:-simd=)' ]
MOZJPEG_V1 = $(MOZJPEG_V2)
MOZJPEG_V2 = \
	docker_opts='-f Dockerfile.v2'; \
	$(SIMD) && docker_opts="$${docker_opts} --build-arg CONFIGURE_OPTS='--with-simd'"; \
	$(BUILD_CMD)
MOZJPEG_V3 = \
	docker_opts='-f Dockerfile.v3'; \
	$(SIMD) && docker_opts="$${docker_opts} --build-arg CONFIGURE_OPTS='--with-simd'"; \
	$(BUILD_CMD)
MOZJPEG_V4 = \
	docker_opts='-f Dockerfile.v4'; \
	$(SIMD) && docker_opts="$${docker_opts} --build-arg CMAKE_OPTS='-D WITH_SIMD=ON -D REQUIRE_SIMD=ON'"; \
	$(BUILD_CMD)
MOZJPEG_CURRENT = $(MOZJPEG_V4)
SIMD_RENAME = if $(SIMD); then find '$(@)' -name '*mozjpeg*' -type f -exec sh -c 'n=mozjpeg; for p in "$${@}"; do d="$${p%/*}"; f=$${p\#\#*/}; mv -- "$${p}" "$${d}/$${f%%$${n}*}$${n}simd$${f\#*$${n}}"; done' sh '{}' +; fi
SET = \
	set -- '$(@:$(BUILD)/%=%)'; \
	tag="$${1%%/*}"; \
	arch="$${1\#*/}"; arch="$${arch%-simd}"
TAGS != git tag -l --sort=version:refname 'v[1-9]*'

IMAGE_ARCHS = 386,amd64,arm/v7,arm64/v8,ppc64le,s390x
IMAGE_AUTHORS = qq542vev <https://purl.org/meta/me/>
IMAGE_DESC = MozJPEG improves JPEG compression efficiency achieving higher visual quality and smaller file sizes at the same time. It is compatible with the JPEG standard, and the vast majority of the world's deployed JPEG decoders.
IMAGE_LICENSE='IJG AND BSD-3-Clause AND Zlib'
IMAGE_TAG = ghcr.io/qq542vev/mozjpeg registry.gitlab.com/qq542vev/mozjpeg
IMAGE_TITLE = MozJPEG
IMAGE_URL = https://gitlab.com/qq542vev/build-mozjpeg

# Build
# =====

all:
	make $(TAGS:%=$(BUILD)/%/all)

$(BUILD)/%/all:
	for target in $(ARCHS:%=$(@D)/%); do make "$${target}" || exit "$${?}"; done

$(ARCHS:%=$(BUILD)/%):
	$(SET); $(MOZJPEG_CURRENT)
	$(SIMD_RENAME)

$(BUILD)/v1.%/arm64/v8-simd $(BUILD)/v2.%/arm64/v8-simd:
	:

$(PARCHS:%=$(BUILD)/v1.%):
	$(SET); $(MOZJPEG_V1)
	$(SIMD_RENAME)

$(PARCHS:%=$(BUILD)/v2.%):
	$(SET); $(MOZJPEG_V2)
	$(SIMD_RENAME)

$(PARCHS:%=$(BUILD)/v3.%):
	$(SET); $(MOZJPEG_V3)
	$(SIMD_RENAME)

$(PARCHS:%=$(BUILD)/v4.%):
	$(SET); $(MOZJPEG_V4)
	$(SIMD_RENAME)

clean:
	rm -rf -- '$(BUILD)'

rebuild: clean
	$(MAKE)

update:
	git fetch --force '$(UPSTREAM)' 'master:master'

publish:
	for tag in $(TAGS); do \
		if [ -d "$(BUILD)/$${tag}" ]; then \
			find "$(BUILD)/$${tag}" ! -name '*.log' -type f -exec glab release create "$${tag}" --name "$${tag}" --notes "see: <https://github.com/mozilla/mozjpeg/releases/tag/$${tag}>" --no-update --use-package-registry '{}' +; \
		fi; \
	done

unpublish:
	for tag in $(TAGS); do \
		if glab release view "$${tag}" >/dev/null 2>&1; then \
			glab release delete "$${tag}" -y; \
		fi; \
	done

image:
	for ver in $(TAGS); do \
		if [ -d "$(BUILD)/$${ver}" ]; then \
			created=$$(date -u '+%Y-%m-%dT%H:%M:%SZ') && \
			docker buildx build \
				$(IMAGE_TAG:%=-t "%:$${ver}") \
				--platform '$(IMAGE_ARCHS)' \
				--build-arg VERSION="$${ver}" --push \
				--label org.opencontainers.image.created="$${created}" \
				--label org.opencontainers.image.authors="$(IMAGE_AUTHORS)" \
				--label org.opencontainers.image.url="$(IMAGE_URL)" \
				--label org.opencontainers.image.version="$${ver}" \
				--label org.opencontainers.image.license="$(IMAGE_LICENSE)" \
				--label org.opencontainers.image.title="$(IMAGE_TITLE)" \
				--label org.opencontainers.image.description="$(IMAGE_DESC)" \
				--annotation org.opencontainers.image.created="$${created}" \
				--annotation org.opencontainers.image.authors="$(IMAGE_AUTHORS)" \
				--annotation org.opencontainers.image.url="$(IMAGE_URL)" \
				--annotation org.opencontainers.image.version="$${ver}" \
				--annotation org.opencontainers.image.license="$(IMAGE_LICENSE)" \
				--annotation org.opencontainers.image.title="$(IMAGE_TITLE)" \
				--annotation org.opencontainers.image.description="$(IMAGE_DESC)" .; \
			fi; \
		done

# Message
# =======

help:
	echo 'ファイルを作成する。'
	echo
	echo 'USAGE:'
	echo '  make [OPTION...] [MACRO=VALUE...] [TARGET...]'
	echo
	echo 'MACRO:'
	echo '  DOCKER_OPTS   dockerコマンドへの追加オプション。'
	echo '  UPSTREAM      リモートリポジトリのアップストリーム用のURL。'
	echo '  IMAGE_ARCHS   --platformの値。'
	echo '  IMAGE_AUTHORS org.opencontainers.image.authorsの値。'
	echo '  IMAGE_DESC    org.opencontainers.image.descriptionの値。'
	echo '  IMAGE_LICENSE org.opencontainers.image.licenseの値。'
	echo '  IMAGE_TAG     レジストリのURL。'
	echo '  IMAGE_TITLE   org.opencontainers.image.titleの値。'
	echo '  IMAGE_URL     org.opencontainers.image.urlの値。'
	echo
	echo 'TARGET:'
	echo '  all       全てのファイルを作成する。'
	echo '  clean     作成したファイルを削除する。'
	echo '  rebuild   cleanの実行後にallを実行する。'
	echo '  update    ローカルリポジトリを更新する。'
	echo '  publish   リリースページを作成する。'
	echo '  unpublish リリースページを削除する。'
	echo '  image     Dockerイメージを生成する。'
	echo '  help      このヘルプを表示して終了する。'
	echo '  version   バージョン情報を表示して終了する。'

version:
	echo '$(VERSION)'
