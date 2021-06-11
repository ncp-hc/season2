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
  server_image_product_code = "SPSW0LINUX000139"
  server_product_code       = "SPSVRSSD00000002"
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
      "yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
      "yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo",
      "yum install -y java-11-openjdk-devel docker-ce docker-ce-cli containerd.io nomad",
      "systemctl enable nomad"
    ]
  }
}
