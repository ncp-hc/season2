# VPC > User scenario > Scenario 2. Public and Private Subnet
# https://docs.ncloud.com/ko/networking/vpc/vpc_userscenario2.html

data "terraform_remote_state" "net" {
  backend = "remote"

  config = {
    organization = "great-stone-biz"
    workspaces = {
      name = "ncp-hc-session2-network"
    }
  }
}

resource "ncloud_login_key" "key_scn_02" {
  key_name = var.name_prerix
}

# Server
resource "ncloud_server" "server_scn_02_public" {
  subnet_no                 = data.terraform_remote_state.net.outputs.subnet_public_id
  name                      = "${var.name_prerix}-public"
  server_image_product_code = "SW.VSVR.OS.LNX64.CNTOS.0703.B050"
  login_key_name            = ncloud_login_key.key_scn_02.key_name
  server_product_code       = "SVR.VSVR.STAND.C002.M008.NET.SSD.B050.G002"
}

// resource "ncloud_server" "server_scn_02_private" {
//   subnet_no                 = ncloud_subnet.subnet_scn_02_private.id
//   name                      = "${var.name_prerix}-private"
//   server_image_product_code = "SW.VSVR.OS.LNX64.CNTOS.0703.B050"
//   login_key_name            = ncloud_login_key.key_scn_02.key_name
//   //server_product_code       = "SVR.VSVR.STAND.C002.M008.NET.SSD.B050.G002"
// }

# Public IP
resource "ncloud_public_ip" "public_ip_scn_02" {
  server_instance_no = ncloud_server.server_scn_02_public.id
  description        = "for ${var.name_prerix}"
}

data "ncloud_root_password" "pwd" {
  server_instance_no = ncloud_server.server_scn_02_public.id
  private_key        = ncloud_login_key.key.private_key
}

output "cn_host_pw" {
  value = nonsensitive("sshpass -p '${data.ncloud_root_password.pwd.root_password}' ssh root@${ncloud_public_ip.public_ip_scn_02.public_ip} -oStrictHostKeyChecking=no")
}
