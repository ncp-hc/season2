packer {
  required_plugins {
    ncloud = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/ncloud"
    }
  }
}

source "ncloud" "nomad-server" {
  access_key                = var.access_key
  secret_key                = var.secret_key
  server_image_product_code = "SW.VSVR.OS.LNX64.CNTOS.0703.B050"
  server_product_code       = "SVR.VSVR.STAND.C002.M008.NET.SSD.B050.G002"
  server_image_name         = var.image_name
  server_image_description  = "server image description"
  region                    = "Korea"
  communicator              = "ssh"
  ssh_username              = "root"
}

build {
  sources = ["source.ncloud.nomad-server"]

  provisioner "file" {
    source = "nomad.service"
    destination = "/etc/systemd/system/nomad.service"
  }

  provisioner "shell" {
    inline = [
      "yum clean all",
      "yum install -y epel-release",
      "yum install -y yum-utils",
      "yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo",
      "yum install -y nomad",
      "systemctl enable nomad"
    ]
  }
}
