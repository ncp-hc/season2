# /etc/consul.d/consul.hcl

data_dir = "/opt/consul"
client_addr = "0.0.0.0"
bind_addr = "{{ GetInterfaceIP `eth0` }}"
ui = true
server = true
bootstrap_expect=1