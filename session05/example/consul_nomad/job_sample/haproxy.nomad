job "lb-haproxy" {
  datacenters = ["dc1"]
  type        = "service"

  group "haproxy" {
    scaling {
      enabled = true
      min = 1
      max = 2
    }

    network {
      port "http" {
        static = 8080
      }

      port "haproxy_ui" {
        static = 1936
      }
    }

    service {
      name = "msa-haproxy"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "haproxy" {
      driver = "docker"

      config {
        image        = "haproxy:2.0"
        network_mode = "host"

        volumes = [
          "local/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg",
        ]
      }

      template {
        data = <<EOF
defaults
   mode http

frontend stats
   bind *:1936
   stats uri /
   stats show-legends
   no log

frontend http_front
   bind *:8080
   default_backend http_back

backend http_back
    balance roundrobin
    server-template ncp-hc 10 _ncpxhc-nodejs._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

resolvers consul
  nameserver consul 127.0.0.1:8600
  accepted_payload_size 8192
  hold valid 5s
EOF

        destination = "local/haproxy.cfg"
      }

      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}