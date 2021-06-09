data "terraform_remote_state" "image_name" {
  backend = "remote"

  config = {
    organization = "great-stone-biz"
    workspaces = {
      name = "ncp-hc-session1-packer"
    }
  }
}

output "image_name" {
    value = terraform_remote_state.image_name.outputs.image_name
}