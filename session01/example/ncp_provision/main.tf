data "terraform_remote_state" "image_name" {
  backend = "remote"

  config = {
    organization = "great-stone-biz"
    workspaces = {
      name = "ncp-hc-session1-packer"
    }
  }
}