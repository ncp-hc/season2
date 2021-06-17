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

resource "ncloud_server" "server" {
  name                      = "${var.server_name}-server-${random_id.id.hex}"
  server_image_product_code = "SPSW0LINUX000139"
  server_product_code       = "SPSVRSSD00000002"
  login_key_name            = ncloud_login_key.key.key_name
  zone                      = var.zone
}

#public ip service
resource "ncloud_public_ip" "public_ip" {
  server_instance_no = ncloud_server.server.id
}

resource "null_resource" "run_sed" {
  depends_on = [ncloud_public_ip.public_ip]

  triggers = {
    server_id = ncloud_server.server.id
  }

  connection {
    type     = "ssh"
    host     = ncloud_public_ip.public_ip.public_ip
    user     = "root"
    port     = "22"
    password = data.ncloud_root_password.rootpwd.root_password
    timeout  = "30s"
  }

  provisioner "file" {
    source      = "file/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sh /tmp/bootstrap.sh"
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

output "vault_url" {
  value = "http://${ncloud_public_ip.public_ip.public_ip}:8200"
}
