# VPC > User scenario > Scenario 2. Public and Private Subnet
# https://docs.ncloud.com/ko/networking/vpc/vpc_userscenario2.html

# VPC
resource "ncloud_vpc" "vpc_scn_02" {
  name            = var.name_scn02
  ipv4_cidr_block = "10.0.0.0/16"
}

# Subnet
resource "ncloud_subnet" "subnet_scn_02_public" {
  name           = "${var.name_scn02}-public"
  vpc_no         = ncloud_vpc.vpc_scn_02.id
  subnet         = cidrsubnet(ncloud_vpc.vpc_scn_02.ipv4_cidr_block, 8, 0)
  // "10.0.0.0/24"
  zone           = "KR-2"
  network_acl_no = ncloud_network_acl.network_acl_02_public.id
  subnet_type    = "PUBLIC"
  // PUBLIC(Public)
}

// resource "ncloud_subnet" "subnet_scn_02_private" {
//   name           = "${var.name_scn02}-private"
//   vpc_no         = ncloud_vpc.vpc_scn_02.id
//   subnet         = cidrsubnet(ncloud_vpc.vpc_scn_02.ipv4_cidr_block, 8, 1)
//   // "10.0.1.0/24"
//   zone           = "KR-2"
//   network_acl_no = ncloud_network_acl.network_acl_02_private.id
//   subnet_type    = "PRIVATE"
//   // PRIVATE(Private)
// }

# Network ACL
resource "ncloud_network_acl" "network_acl_02_public" {
  vpc_no = ncloud_vpc.vpc_scn_02.id
  name   = "${var.name_scn02}-public"
}

resource "ncloud_network_acl" "network_acl_02_private" {
  vpc_no = ncloud_vpc.vpc_scn_02.id
  name   = "${var.name_scn02}-private"
}

# NAT Gateway
resource "ncloud_nat_gateway" "nat_gateway_scn_02" {
  vpc_no = ncloud_vpc.vpc_scn_02.id
  zone   = "KR-2"
  name   = var.name_scn02
}

# Route Table
resource "ncloud_route" "route_scn_02_nat" {
  route_table_no         = ncloud_vpc.vpc_scn_02.default_private_route_table_no
  destination_cidr_block = "0.0.0.0/0"
  target_type            = "NATGW"
  // NATGW (NAT Gateway) | VPCPEERING (VPC Peering) | VGW (Virtual Private Gateway).
  target_name            = ncloud_nat_gateway.nat_gateway_scn_02.name
  target_no              = ncloud_nat_gateway.nat_gateway_scn_02.id
}