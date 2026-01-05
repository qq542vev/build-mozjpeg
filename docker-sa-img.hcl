### File: docker-sa-img.hcl
##
## MozJPEGのみのDockerイメージを組み立てる。
##
## Usage:
##
## ------ Text ------
## docker buildx bake -f docker-sa-img.hcl
## ------------------
##
## Env variable:
##
##   DIR - ビルド済みのソフトウェアが配置されているディレクトリ。
##   IMG_AUTHS - org.opencontainers.image.authorsの値。
##   IMG_CREATED - org.opencontainers.image.createdの値。
##   IMG_DESC - org.opencontainers.image.descの値。
##   IMG_LICENSE- org.opencontainers.image.licenseの値。
##   IMG_TITLE - org.opencontainers.image.titleの値。
##   IMG_URL - org.opencontainers.image.urlの値。
##   REV - Gitリポジトリのリビジョン識別子。
##
## Metadata:
##
##   id - f37e7113-0027-4962-9e2a-34cf11751294
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   created - 2026-01-04
##   modified - 2026-01-04
##   copyright - Copyright (C) 2026-2026 qq542vev. All rights reserved.
##   license - <GPL-3.0-only at https://www.gnu.org/licenses/gpl-3.0.txt>
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/build-mozjpeg>
##   * <Bag report at https://github.com/qq542vev/build-mozjpeg/issues>

variable "DIR" {default = "build/v4.1.5"}
variable "REV" {default = regex("[^/]+$", "${DIR}")}
variable "IMG_AUTHS" {default = "qq542vev <https://purl.org/meta/me/>"}
variable "IMG_CREATED" {default = timestamp()}
variable "IMG_DESC" {default = "MozJPEG improves JPEG compression efficiency achieving higher visual quality and smaller file sizes at the same time. It is compatible with the JPEG standard, and the vast majority of the world's deployed JPEG decoders."}
variable "IMG_LICENSE" {default = "IJG AND BSD-3-Clause AND Zlib"}
variable "IMG_TITLE" {default = "MozJPEG"}
variable "IMG_URL" {default = "https://gitlab.com/qq542vev/build-mozjpeg"}
variable "labels" {
  default = {
    "org.opencontainers.image.created" = IMG_CREATED
    "org.opencontainers.image.authors" = IMG_AUTHS
    "org.opencontainers.image.url" = IMG_URL
    "org.opencontainers.image.version" = REV
    "org.opencontainers.image.license" = IMG_LICENSE
    "org.opencontainers.image.title" = IMG_TITLE
    "org.opencontainers.image.description" = IMG_DESC
  }
}

target "default" {
  context = "."
  dockerfile = "Dockerfile.standalone"
  platforms = ["linux/amd64", "linux/arm/v7", "linux/arm64", "linux/ppc64le", "linux/s390x"]
  args = {
    DIR = DIR
  }
  labels = labels
  annotations = formatlist("%s=%s", keys(labels), values(labels))
  tags = [
    "ghcr.io/qq542vev/build-mozjpeg:${REV}",
    "registry.gitlab.com/qq542vev/build-mozjpeg:${REV}"
  ]
  output = ["type=registry"]
}
