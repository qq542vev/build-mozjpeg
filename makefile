#!/usr/bin/gmake -f

### Script: makefile
##
## ファイルを作成する。
##
## Metadata:
##
##   id - 12d86b83-9061-4112-8010-eab2952c051d
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   created - 2025-11-15
##   modified - 2025-11-15
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

.PHONY: all clean rebuild update help version

.SILENT: help version

# Macro
# =====

VERSION = 1.0.0

BUILD = build
ARCHS = 386 386-simd amd64 amd64-simd arm/v7 arm/v7-simd arm64/v8 ppc64le s390x
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
SMID = [ '$(@)' != '$(@:-simd=)' ]
MOZJPEG_V1 = $(MOZJPEG_V2)
MOZJPEG_V2 = \
	docker_opts='-f Dockerfile.v2'; \
	$(SMID) && docker_opts="$${docker_opts} --build-arg CONFIGURE_OPTS='--with-simd'"; \
	$(BUILD_CMD)
MOZJPEG_V3 = \
	docker_opts='-f Dockerfile.v3'; \
	$(SMID) && docker_opts="$${docker_opts} --build-arg CONFIGURE_OPTS='--with-simd'"; \
	$(BUILD_CMD)
MOZJPEG_V4 = \
	docker_opts='-f Dockerfile.v4'; \
	$(SMID) && docker_opts="$${docker_opts} --build-arg CMAKE_OPTS='-D WITH_SIMD=ON -D REQUIRE_SIMD=ON'"; \
	$(BUILD_CMD)
MOZJPEG_CURRENT = $(MOZJPEG_V4)
SIMD_RENAME = if $(SMID); then find '$(@)' -name '*mozjpeg*' -type f -exec sh -c 'n=mozjpeg; for p in "$${@}"; do d="$${p%/*}"; f=$${p\#\#*/}; mv -- "$${p}" "$${d}/$${f%%$${n}*}$${n}simd$${f\#*$${n}}"; done' sh '{}' +; fi
SET = \
	set -- '$(@:$(BUILD)/%=%)'; \
	tag="$${1%%/*}"; \
	arch="$${1\#*/}"; arch="$${arch%-simd}"

# Build
# =====

all:
	make $$(git tag | sed -En 's#^v[1-9][0-9]*(\.(0|[1-9][0-9]*)){0,2}$$#$(BUILD)/&/all#p')

$(BUILD)/%/all:
	for target in $(ARCHS:%=$(@D)/%); do make "$${target}" || exit "$${?}"; done

$(ARCHS:%=$(BUILD)/%):
	$(SET); $(MOZJPEG_CURRENT)
	$(SIMD_RENAME)

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
	git fetch --force '$(UPSTREAM)'  'master:master'

# Message
# =======

help:
	echo 'ファイルを作成する。'
	echo
	echo 'USAGE:'
	echo '  make [OPTION...] [MACRO=VALUE...] [TARGET...]'
	echo
	echo 'MACRO:'
	echo '  DOCKER_OPTS dockerコマンドへの追加オプション。'
	echo '  UPSTREAM    Gitのアップストリーム用のURL。'
	echo
	echo 'TARGET:'
	echo '  all     全てのファイルを作成する。'
	echo '  clean   作成したファイルを削除する。'
	echo '  rebuild cleanの実行後にallを実行する。'
	echo '  update  ローカルリポジトリを更新する。'
	echo '  help    このヘルプを表示して終了する。'
	echo '  version バージョン情報を表示して終了する。'

version:
	echo '$(VERSION)'
