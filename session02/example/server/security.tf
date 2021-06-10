# Network ACL Rule
locals {
  public_subnet_outbound = [
    [4, "TCP", "${ncloud_server.server_scn_02_private.network_interface[0].private_ip}/32", "8080", "ALLOW"],
  ]
}

resource "ncloud_network_acl_rule" "network_acl_02_rule_public" {
  network_acl_no = ncloud_network_acl.network_acl_02_public.id

  dynamic "outbound" {
    for_each = local.public_subnet_outbound
    content {
      priority    = outbound.value[0]
      protocol    = outbound.value[1]
      ip_block    = outbound.value[2]
      port_range  = outbound.value[3]
      rule_action = outbound.value[4]
    }
  }
}

locals {
  private_subnet_inbound = [
    [1, "TCP", "${ncloud_server.server_scn_02_public.network_interface[0].private_ip}/32", "8080", "ALLOW"],
  ]

  private_subnet_outbound = [
    [1, "TCP", "${ncloud_server.server_scn_02_public.network_interface[0].private_ip}/32", "32768-65535", "ALLOW"],
  ]
}

resource "ncloud_network_acl_rule" "network_acl_02_private" {
  network_acl_no = ncloud_network_acl.network_acl_02_private.id

  dynamic "inbound" {
    for_each = local.private_subnet_inbound
    content {
      priority    = inbound.value[0]
      protocol    = inbound.value[1]
      ip_block    = inbound.value[2]
      port_range  = inbound.value[3]
      rule_action = inbound.value[4]
    }
  }

  dynamic "outbound" {
    for_each = local.private_subnet_outbound
    content {
      priority    = outbound.value[0]
      protocol    = outbound.value[1]
      ip_block    = outbound.value[2]
      port_range  = outbound.value[3]
      rule_action = outbound.value[4]
    }
  }
}