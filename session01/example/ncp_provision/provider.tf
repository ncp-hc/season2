terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
      version = "2.1.0"
    }
  }
}

provider "ncloud" {
  region = var.region
  site   = var.site
  access_key = var.access_key
  secret_key = var.secret_key
}
