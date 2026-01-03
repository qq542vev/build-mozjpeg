variable "MOZJPEG_TAG" {default = "v4.1.5"}
variable "MOZJPEG_ARCH" {default = "386"}
variable "mver" {
  default = try(regex("^v[1-4]", "${MOZJPEG_TAG}"), "v4")
}

target "default" {
  context = "."
  dockerfile = "Dockerfile.${mver}"
  platforms = ["linux/${MOZJPEG_ARCH}"]
  args = {
    MOZJPEG_TAG = MOZJPEG_TAG
  }
  secrets = [
    "id=attach,src=attach.yaml"
  ]
  output = [
    "type=tar,dest=-"
  ]
}
