# waypoint install -platform=docker -accept-tos
# waypoint token new > waypoint_token.txt
# waypoint init
# waypoint up

project = "example-java"

app "example-java" {

  labels = {
    "service" = "example-java",
    "env"     = "dev"
  }

  build {
    use "pack" {
      // builder = "gcr.io/buildpacks/builder:v1"
    }
    registry {
      use "docker" {
        image = "nodejstest.kr.ncr.ntruss.com/java-docker"
        tag   = "latest"
        encoded_auth = filebase64("./dockerAuth.json")
      }
    }
  }

  deploy {
    use "kubernetes" {
      namespace    = "default"
      replicas = 1
      probe_path   = "/"
      service_port = 8080
      kubeconfig = "kubeconfig.yaml"
    }
  }

  release {
    use "kubernetes" {
      // node_port = 32000
      load_balancer = true
    }
  }
}
