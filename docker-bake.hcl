### File: docker-bake.hcl
##
## MozJPEGを組み立てる。
##
## Usage:
##
## ------ Text ------
## docker buildx bake -f docker-bake.hcl
## ------------------
##
## Env variable:
##
##   ARCH - ビルド対象のアーキテクチャ。
##   DOCKERFILE - Dockerfile。
##   REV - Gitリポジトリのリビジョン識別子。
##
## Metadata:
##
##   id - a4606dd2-d980-4994-acac-20ceafa2d0c7
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

variable "REV" {default = "v4.1.5"}
variable "ARCH" {default = "386"}
variable "DOCKERFILE" {
  default = try("Dockerfile.${regex("^v[1-9][0-9]*", "${REV}")}", "Dockerfile")
}

target "default" {
  context = "."
  dockerfile = "${DOCKERFILE}"
  platforms = ["linux/${ARCH}"]
  args = {
    REV = REV
  }
  secrets = [
    "id=attach,src=attach.yaml"
  ]
  output = [
    "type=tar,dest=-"
  ]
}
