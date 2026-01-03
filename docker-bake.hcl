variable "REV" {default = "v4.1.5"}
variable "ARCH" {default = "386"}
variable "mver" {
  default = try(regex("^v[1-4]", "${REV}"), "v4")
}

target "default" {
  context = "."
  dockerfile = "Dockerfile.${mver}"
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
