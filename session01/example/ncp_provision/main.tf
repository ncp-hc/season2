data "terraform_remote_state" "image_name" {
  backend = "remote"

  config = {
    organization = "great-stone-biz"
    workspaces = {
      name = "ncp-hc-session1-packer"
    }
  }
}

output "image_name" {
    value = terraform_remote_state.image_name.outputs.image_name
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

data "ncloud_port_forwarding_rules" "rules" {
  zone = ncloud_server.server.zone
}

data "ncloud_member_server_image" "prod" {
 name_regex = teraform_remote_state.image_name.outputs.image_name
}

resource "ncloud_server" "server" {
  name                      = "${var.server_name}${random_id.id.hex}"
  member_server_image_no    = data.ncloud_member_server_image.prod.no 
  server_product_code       = "SPSVRGPUSSD00001" 
  login_key_name            = ncloud_login_key.key.key_name
  zone                      = var.zone
}

#port forwarding 22 port for this host
resource "ncloud_port_forwarding_rule" "forwarding" {
  port_forwarding_configuration_no = data.ncloud_port_forwarding_rules.rules.id
  server_instance_no               = ncloud_server.server.id
  port_forwarding_external_port    = var.port_forwarding_external_port
  port_forwarding_internal_port    = "22"
}

#public ip service
resource "ncloud_public_ip" "public_ip" {
  server_instance_no = ncloud_server.server.id
}


resource "null_resource" "ssh" {
  provisioner "local-exec" {
    command = <<EOF
    
EOF
  }
}
