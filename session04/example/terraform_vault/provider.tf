terraform {
  required_providers {
    ncloud = {
      source  = "NaverCloudPlatform/ncloud"
      version = "2.1.0"
    }
  }
  backend "remote" {
    organization = "great-stone-biz"

    workspaces {
      name = "ncp-hc-session4-secure-cicd"
    }
  }
}

provider "ncloud" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "vault" {
  address = "http://${ncloud_public_ip.public_ip.public_ip}:8200"
  auth_login {
    path = "auth/userpass/login/admin"
    parameters = {
      password = "password"
    }
  }
}