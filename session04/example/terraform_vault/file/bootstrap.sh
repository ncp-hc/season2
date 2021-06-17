#!/bin/bash
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum update -y
yum -y install vault nc
sed -i'' -r -e "/0.0.0.0:8200/a\  tls_disable = 1" /etc/vault.d/vault.hcl

systemctl enable vault
systemctl start vault
export VAULT_SKIP_VERIFY=True
export VAULT_ADDR='http://127.0.0.1:8200'

# wait service running
while( ! nc -z 127.0.0.1 8200 ); do echo "wait Vault service"; sleep 5; done

# execute the vault operator init command to initialize Vault:
export FILE=/etc/vault.d/key.txt
if [ ! -f "$FILE" ]; then
    vault operator init > $FILE
fi
cd /etc/vault.d

sleep 2

# By default, the number of shared keys is 5 and quorum of 3 unseal keys are required to unseal vault (key.txt)
vault operator unseal $(grep 'Key 1:' key.txt | awk '{print $NF}')
sleep 1
vault operator unseal $(grep 'Key 2:' key.txt | awk '{print $NF}')
sleep 1
vault operator unseal $(grep 'Key 3:' key.txt | awk '{print $NF}')
sleep 1

# Log into Vault using the initial root token (key.txt)
grep 'Initial Root Token:' key.txt | awk '{print $NF}'
vault login $(grep 'Initial Root Token:' key.txt | awk '{print $NF}')

# Create Admin User
vault auth enable userpass

vault policy write super-user - << EOF
path "*" {
capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

vault write auth/userpass/users/admin password=password policies=super-user
