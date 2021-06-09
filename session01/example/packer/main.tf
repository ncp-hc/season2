locals {
  timestamp       = formatdate("YYYYMMDD-hhmmss", timeadd(timestamp(), "9h"))
  last_image_name = "${var.image_name_prefix}_${local.timestamp}"
}

resource "null_resource" "run_packer" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOH
cd ./pkr_hcl
unzip ./packer_1.7.2_linux_amd64.zip
echo $${NCP_ACCESS_KEY}
echo $${NCP_SECRET_KEY}
./packer version
./packer init ./ncloud.pkr.hcl
./packer build \
    -var 'image_name=${local.last_image_name}' \
    -var 'access_key=$${NCP_ACCESS_KEY}' \
    -var 'secret_key=$${NCP_SECRET_KEY}' \
    -force \
    -color=false \
    .
EOH
  }
}