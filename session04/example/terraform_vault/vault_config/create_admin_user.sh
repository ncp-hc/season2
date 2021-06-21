export VAULT_ADDR=http://yourVaultAddress:8200
export VAULT_TOKEN=<your root token>

vault auth enable userpass

vault policy write super-user - << EOF
path "*" {
capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

vault write auth/userpass/users/admin password=password policies=super-user