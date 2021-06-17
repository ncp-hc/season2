resource "vault_mount" "kvv2-ncp" {
  path        = "kv"
  type        = "kv-v2"
  description = "This is an example KV Version 2 secret engine mount"
}

resource "vault_policy" "ncp" {
  name = "ncp-cicd"

  policy = <<EOT
path "kv/*" {
  capabilities = ["read"]
}
EOT
}

resource "vault_token" "cicd" {
  depends_on = [vault_policy.ncp]
  policies   = ["ncp-cicd"]

  renewable = true
  ttl       = "24h"

  renew_min_lease = 43200
  renew_increment = 86400
}

output "cicd_token" {
  value = nonsensitive(vault_token.cicd.client_token)
}