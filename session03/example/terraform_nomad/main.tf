data "terraform_remote_state" "image_name" {
  backend = "remote"

  config = {
    organization = "great-stone-biz"
    workspaces = {
      name = "ncp-hc-session3-packer"
    }
  }
}

output "image_name" {
  value = data.terraform_remote_state.image_name.outputs.image_name
}
output "image_no" {
  value = data.ncloud_member_server_images.prod.member_server_images.0
}

resource "random_id" "id" {
  byte_length = 4
}

resource "ncloud_login_key" "key" {
  key_name = "${var.login_key_name}${random_id.id.hex}"
}

data "ncloud_root_password" "rootpwd" {
  server_instance_no = ncloud_server.server.id
  private_key        = ncloud_login_key.key.private_key
}

data "ncloud_root_password" "rootpwd_client" {
  count              = var.nomad_client_count
  server_instance_no = ncloud_server.client[count.index].id
  private_key        = ncloud_login_key.key.private_key
}

// data "ncloud_port_forwarding_rules" "rules" {
//   zone = ncloud_server.server.zone
// }

data "ncloud_member_server_images" "prod" {
  #name_regex = data.terraform_remote_state.image_name.outputs.image_name
  filter {
    name   = "name"
    values = [data.terraform_remote_state.image_name.outputs.image_name]
  }
}

resource "ncloud_server" "server" {
  name                   = "${var.server_name}-server-${random_id.id.hex}"
  member_server_image_no = data.ncloud_member_server_images.prod.member_server_images.0
  server_product_code    = "SPSVRSSD00000002"
  login_key_name         = ncloud_login_key.key.key_name
  zone                   = var.zone
}

// resource "ncloud_init_script" "init" {
//   name    = "ls-script"
//   content = <<EOC
//     #!bin/bash
//     cat <<EOF> /etc/nomad.d/nomad.hcl
//     data_dir = "/opt/nomad/data"
//     bind_addr = "0.0.0.0"

//     client {
//       enabled = true
//       servers = ["${ncloud_server.server.private_ip}:4646"]
//     }
//     EOF
//     systemctl restart nomad
//   EOC
// }

resource "ncloud_server" "client" {
  depends_on = [ncloud_server.server]
  count                  = var.nomad_client_count
  name                   = "${var.server_name}-client-${count.index}"
  member_server_image_no = data.ncloud_member_server_images.prod.member_server_images.0
  server_product_code    = "SPSVRSSD00000002"
  login_key_name         = ncloud_login_key.key.key_name
  zone                   = var.zone
  // init_script_no            = ncloud_init_script.init.id
}

#public ip service
resource "ncloud_public_ip" "public_ip" {
  server_instance_no = ncloud_server.server.id
}

resource "ncloud_public_ip" "public_ip_client" {
  count              = var.nomad_client_count
  server_instance_no = ncloud_server.client[count.index].id
}

resource "null_resource" "run_sed" {

  depends_on = [ncloud_public_ip.public_ip_client]
  count      = var.nomad_client_count

  triggers = {
    always_run = timestamp()
  }

  connection {
    type     = "ssh"
    host     = ncloud_public_ip.public_ip_client[count.index].public_ip
    user     = "root"
    port     = "22"
    password = data.ncloud_root_password.rootpwd_client[count.index].root_password
    timeout  = "30s"
  }

  provisioner "file" {
    destination = "/etc/nomad.d/nomad.hcl"
    content     = <<EOC
data_dir = "/opt/nomad/data"
bind_addr = "0.0.0.0"

client {
  enabled = true
  servers = ["${ncloud_server.server.private_ip}"]
}
    EOC
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl restart nomad"
    ]
  }
}

resource "null_resource" "host_provisioner" {
  provisioner "remote-exec" {
    inline = [
      "touch /tmp/test"
    ]
  }

  connection {
    type     = "ssh"
    host     = ncloud_public_ip.public_ip.public_ip
    user     = "root"
    port     = "22"
    password = data.ncloud_root_password.rootpwd.root_password
  }
}

output "server_ssh_pw" {
  value = nonsensitive("sshpass -p '${data.ncloud_root_password.rootpwd.root_password}' ssh root@${ncloud_public_ip.public_ip.public_ip} -oStrictHostKeyChecking=no")
}

output "client_ssh_pw" {
  value = var.nomad_client_count > 0 ? nonsensitive("sshpass -p '${data.ncloud_root_password.rootpwd_client[0].root_password}' ssh root@${ncloud_public_ip.public_ip_client[0].public_ip} -oStrictHostKeyChecking=no") : null
}

output "server_url" {
  value = "http://${ncloud_public_ip.public_ip.public_ip}:4646"
}
