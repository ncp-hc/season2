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
pwd
unzip packer_1.7.2_linux_amd64.zip
./packer version
./packer init ./ncloud.pkr.hcl
./packer build \
    -var 'image_name=${local.last_image_name}' \
    -var 'access_key=${var.access_key}' \
    -var 'secret_key=${var.secret_key}' \
    -force \
    -color=false \
    ./pkr_hcl
EOH
  }
}