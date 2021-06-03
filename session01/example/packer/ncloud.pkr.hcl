packer {
  required_plugins {
    ncloud = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/ncloud"
    }
  }
}

variable "access_key" {
  type    = string
  default = ""
}

variable "secret_key" {
  type    = string
  default = ""
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "ncloud" "example-linux" {
  access_key                = "${var.access_key}"
  secret_key                = "${var.secret_key}"
  server_image_product_code = "SPSW0LINUX000139"
  server_product_code       = "SPSVRGPUSSD00001"
  server_image_name         = "packer-${local.timestamp}"
  server_image_description  = "server image description"
  region                    = "Korea"
  communicator              = "ssh"
  ssh_username              = "root"
}

build {
  sources = ["source.ncloud.example-linux"]

  provisioner "shell" {
    inline = [
      "echo Connected via SSM at '${build.User}@${build.Host}:${build.Port}'"
    ]
  }
}
