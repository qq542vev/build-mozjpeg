variable "REVISION" {default = "v4.1.5"}
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
    "org.opencontainers.image.version" = REVISION
    "org.opencontainers.image.license" = IMAGE_LICENSE
    "org.opencontainers.image.title" = IMAGE_TITLE
    "org.opencontainers.image.description" = IMAGE_DESC
  }
}

target "default" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm/v7", "linux/ppc64le", "linux/s390x"]
  args {
    REVISION = REVISION
  }
  labels = labels
  annotations = formatlist("%s=%s", keys(labels), values(labels))
  tags = [
    "ghcr.io/qq542vev/mozjpeg:${REVISION}",
    "registry.gitlab.com/qq542vev/mozjpeg:${REVISION}"
  ]
  output = ["type=registry"]
}
