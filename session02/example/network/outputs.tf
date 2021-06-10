output "acl_public_id" {
  value = ncloud_network_acl.network_acl_02_public.id
}

output "acl_private_id" {
  value = ncloud_network_acl.network_acl_02_private.id
}

output "subnet_public_id" {
  value = ncloud_subnet.subnet_scn_02_public.id
}