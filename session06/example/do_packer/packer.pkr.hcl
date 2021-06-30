# packer init .
# packer build -var-file=variables.pkrvars.hcl .
# docker run -p 8080:8080 nodejstest.kr.ncr.ntruss.com/java-docker:packer

packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "example" {
  image = "openjdk:11"
  # export_path = "image.tar"
  message = "Packer build done!!"
  commit  = true
  changes = [
    "VOLUME /tmp",
    "ENTRYPOINT java -Djava.security.egd=file:/dev/./urandom -jar /app.jar",
  ]
}

build {
  sources = ["source.docker.example"]

  provisioner "file" {
    source = "../sample_java/target/waypoint-0.0.1-SNAPSHOT.jar"
    destination = "app.jar"
  }

  post-processors {
    # post-processor "docker-import" {
    #     repository =  "java-docker"
    #     tag = ["packer"]
    # }
    post-processor "docker-tag" {
      repository = "nodejstest.kr.ncr.ntruss.com/java-docker"
      tag        = ["packer"]
    }
    post-processor "docker-push" {
      login_username = var.access_key
      login_password = var.secret_key
      login_server   = "https://nodejstest.kr.ncr.ntruss.com/"
    }
  }
}

variable "access_key" {}
variable "secret_key" {}