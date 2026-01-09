#!/usr/bin/gmake -f

### Script: makefile
##
## ファイルを作成する。
##
## Metadata:
##
##   id - 12d86b83-9061-4112-8010-eab2952c051d
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.2.3
##   created - 2025-11-15
##   modified - 2026-01-09
##   copyright - Copyright (C) 2025-2026 qq542vev. All rights reserved.
##   license - <GPL-3.0-only at https://www.gnu.org/licenses/gpl-3.0.txt>
##   depends - docker, find, git, glab, mkdir, mv, rm, tar, test
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

.SHELLFLAGS = -efuo pipefail -c

VERSION = 1.2.3

DIR = build
ARCHS = 386 386-simd amd64 amd64-simd arm/v7 arm/v7-simd arm64 arm64-simd ppc64le s390x
PARCHS != for arch in $(ARCHS); do echo "%/$${arch}"; done
UPSTREAM = https://github.com/mozilla/mozjpeg.git

DOCKER = eval docker buildx bake --progress plain $${opts-} $(DOCKER_OPTS) | tar -xvC '$(@)'
CMD = { mkdir -p -- '$(@)' && $(DOCKER); }
SIMD = [ '$(@)' != '$(@:-simd=)' ]
MOZJPEG_V1 = \
	$(SIMD) && opts="--set '*.args.CONFIGURE_OPTS=--with-simd'"; \
	$(CMD)
MOZJPEG_V2 = $(MOZJPEG_V1)
MOZJPEG_V3 = $(MOZJPEG_V2)
MOZJPEG_V4 = \
	$(SIMD) && opts="--set '*.args.CMAKE_OPTS=-D WITH_SIMD=ON -D REQUIRE_SIMD=ON'"; \
	$(CMD)
MOZJPEG_CURR = $(MOZJPEG_V4)
SIMD_RENAME = if $(SIMD); then find '$(@)' -name '*mozjpeg*' -type f -exec sh -c 'n=mozjpeg; for p in "$${@}"; do d="$${p%/*}"; f=$${p\#\#*/}; mv -- "$${p}" "$${d}/$${f%%$${n}*}$${n}simd$${f\#*$${n}}"; done' sh '{}' +; fi
SET = \
	trap '[ "$${?}" -ne 0 ] && rm -rf "$(@)"' EXIT HUP INT QUIT TERM; \
	set -- '$(@:$(DIR)/%=%)'; \
	ARCH="$${1\#*/}"; \
	export ARCH="$${ARCH%-simd}" REV="$${1%%/*}"
TAGS != git tag -l --sort=version:refname 'v[1-9]*'

# Build
# =====

all:
	$(MAKE) $(TAGS:%=$(DIR)/%/all)

$(DIR)/%/all:
	for target in $(ARCHS:%=$(@D)/%); do $(MAKE) "$${target}"; done

$(ARCHS:%=$(DIR)/%):
	$(SET); $(MOZJPEG_CURR)
	$(SIMD_RENAME)

$(DIR)/v1.%/arm64-simd $(DIR)/v2.%/arm64-simd:
	:

$(PARCHS:%=$(DIR)/v1.%):
	$(SET); $(MOZJPEG_V1)
	$(SIMD_RENAME)

$(PARCHS:%=$(DIR)/v2.%):
	$(SET); $(MOZJPEG_V2)
	$(SIMD_RENAME)

$(PARCHS:%=$(DIR)/v3.%):
	$(SET); $(MOZJPEG_V3)
	$(SIMD_RENAME)

$(PARCHS:%=$(DIR)/v4.%):
	$(SET); $(MOZJPEG_V4)
	$(SIMD_RENAME)

clean:
	rm -rf -- '$(DIR)'

rebuild: clean
	$(MAKE)

update:
	git fetch --force '$(UPSTREAM)' 'master:master'

publish:
	for tag in $(TAGS); do \
		if [ -d "$(DIR)/$${tag}" ]; then \
			find "$(DIR)/$${tag}" ! -name '*.log' -type f -exec glab release create "$${tag}" --name "$${tag}" --notes "see: <https://github.com/mozilla/mozjpeg/releases/tag/$${tag}>" --no-update --use-package-registry '{}' +; \
		fi; \
	done

unpublish:
	for tag in $(TAGS); do \
		if glab release view "$${tag}" >/dev/null 2>&1; then \
			glab release delete "$${tag}" -y; \
		fi; \
	done

image:
	for tag in $(TAGS); do \
		if [ -d "$(DIR)/$${tag}" ]; then \
			DIR="$(DIR)/$${tag}" docker buildx bake -f docker-sa-img.hcl; \
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
