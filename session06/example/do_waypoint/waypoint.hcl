# docker stop waypoint-server
# docker rm waypoint-server
# docker volume rm waypoint-server
# waypoint install -platform=docker -accept-tos
# waypoint token new > waypoint_token.txt
# waypoint init
# waypoint up

project = "example-java"

// runner {
//   enabled = true

//   data_source "git" {
//     url  = "https://github.com/ncp-hc/season2.git"
//     path = "session06/example/do_waypoint"
//   }
// }

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
        tag   = "waypoint"
        encoded_auth = filebase64("${path.app}/dockerAuth.json")
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
      image_secret = "regcred"
    }
    // use "nomad" {
    //   region     = "global"
    //   datacenter = "hashistack"
    //   namespace  = "waypoint"
    //   replicas   = 1
    // }
  }

  release {
    use "kubernetes" {
      // node_port = 32000
      kubeconfig = "kubeconfig.yaml"
      load_balancer = true
    }
  }
}
