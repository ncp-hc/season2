job "ncpxhc_nodejs" {
  datacenters = ["dc1"]

  type = "service"

  group "ncpxhc" {
    scaling {
      enabled = true
      min = 1
      max = 10
    }

    task "nodejs" {
      driver = "docker"

      config {
        image = "nodejstest.kr.ncr.ntruss.com/serverjs:latest"
        auth {
            username = "<ncp_access_key>"
            password = "<ncp_secret_key>"
            server_address = "nodejstest.kr.ncr.ntruss.com"
        }
        port_map {
          http = 3000
        }
      }
      resources {
        cpu = 200
        memory = 256

        network {
          mbits = 10
          port "http" {
            # static = 3306
          }
        }
      }

      service {
        name = "ncpxhc-nodejs"
        tags = ["v1", "ncp", "hashicorp", "session5"]
        port  = "http"
        check {
          type  = "tcp"
          port  = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
