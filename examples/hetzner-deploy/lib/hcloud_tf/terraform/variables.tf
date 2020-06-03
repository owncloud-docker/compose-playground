variable "hcloud_token" {
  type = "string"
}

variable "server_names" {
  type = "list"

  default = [
    "jw-test"
  ]
}

variable "server_types" {
  type = "list"

  default = [
    "cx21",
  ]
}

variable "server_image" {
  type    = "string"
  default = "ubuntu-20.04"
}

variable "server_datacenter" {
  type    = "string"
  default = "fsn1-dc14"
#  default = "nbg1-dc3"
}

variable "server_origin" {
  type    = "string"
  default = "make_machine.sh"
}

variable "server_owner" {
  type    = "string"
  default = "anonymous-user-of-gitea.jw.hetzner"
}

variable "server_keys" {
  type = "list"

  default = [
#    "jw@owncloud.com",
  ]
}

variable "ssh_keys" {
  type = "list"

  default = [
  ]
}
