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
##   IMAGE_AUTHORS - org.opencontainers.image.authorsの値。
##   IMAGE_CREATED - org.opencontainers.image.createdの値。
##   IMAGE_DESC - org.opencontainers.image.descの値。
##   IMAGE_LICENSE- org.opencontainers.image.licenseの値。
##   IMAGE_TITLE - org.opencontainers.image.titleの値。
##   IMAGE_URL - org.opencontainers.image.urlの値。
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
variable "IMAGE_AUTHORS" {default = "qq542vev <https://purl.org/meta/me/>"}
variable "IMAGE_CREATED" {default = timestamp()}
variable "IMAGE_DESC" {default = "MozJPEG improves JPEG compression efficiency achieving higher visual quality and smaller file sizes at the same time. It is compatible with the JPEG standard, and the vast majority of the world's deployed JPEG decoders."}
variable "IMAGE_LICENSE" {default = "IJG AND BSD-3-Clause AND Zlib"}
variable "IMAGE_TITLE" {default = "MozJPEG"}
variable "IMAGE_URL" {default = "https://gitlab.com/qq542vev/build-mozjpeg"}
variable "labels" {
  default = {
    "org.opencontainers.image.created" = IMAGE_CREATED
    "org.opencontainers.image.authors" = IMAGE_AUTHORS
    "org.opencontainers.image.url" = IMAGE_URL
    "org.opencontainers.image.version" = REV
    "org.opencontainers.image.license" = IMAGE_LICENSE
    "org.opencontainers.image.title" = IMAGE_TITLE
    "org.opencontainers.image.description" = IMAGE_DESC
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
    "ghcr.io/qq542vev/mozjpeg:${REV}",
    "registry.gitlab.com/qq542vev/mozjpeg:${REV}"
  ]
  output = ["type=registry"]
}
