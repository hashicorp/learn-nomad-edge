variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type        = list(string)
  default     = ["dc2"]
}

variable "region" {
  description = "The region where the job should be placed."
  type        = string
  default     = "global"
}

variable "frontend_version" {
  description = "Docker version tag"
  default = "v1.0.3"
}

variable "public_api_version" {
  description = "Docker version tag"
  default = "v0.0.6"
}

variable "payments_version" {
  description = "Docker version tag"
  default = "v0.0.12"
}

variable "frontend_port" {
  description = "Frontend Port"
  default = 3000
}

variable "payments_api_port" {
  description = "Payments API Port"
  default = 8080
}

variable "public_api_port" {
  description = "Public API Port"
  default = 8081
}

variable "nginx_port" {
  description = "Nginx Port"
  default = 80
}

# Begin Job Spec
job "hashicups-edge" {
  type   = "service"
  region = var.region
  datacenters = var.datacenters

  group "hashicups-edge" {
    network {
      port "frontend" {
        static = var.frontend_port
      }
      port "payments-api" {
        static = var.payments_api_port
      }
      port "public-api" {
        static = var.public_api_port
      }
      port "nginx" {
        static = var.nginx_port
      }
    }

    task "payments-api" {
      driver = "docker"
      meta {
        service = "payments-api"
      }
      service {
        port     = "payments-api"
        tags     = ["hashicups", "backend"]
        provider = "nomad"
        address      = attr.unique.platform.aws.public-ipv4
      }
      config {
        image   = "hashicorpdemoapp/payments:${var.payments_version}"
        ports = ["payments-api"]
        mount {
          type   = "bind"
          source = "local/application.properties"
          target = "/application.properties"
        }
      }
      template {
        data = "server.port=${var.payments_api_port}"
        destination = "local/application.properties"
      }
    }
    
    task "public-api" {
      driver = "docker"
      meta {
        service = "public-api"
      }
      service {
        port     = "public-api"
        tags     = ["hashicups", "backend"]
        provider = "nomad"
        address      = attr.unique.platform.aws.public-ipv4
      }
      config {
        image   = "hashicorpdemoapp/public-api:${var.public_api_version}"
        ports = ["public-api"]
      }
      template {
        data        = <<EOH
{{ range nomadService "hashicups-hashicups-product-api" }}
PRODUCT_API_URI="http://{{.Address}}:{{.Port}}"
{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }
      env {
        BIND_ADDRESS = ":${NOMAD_PORT_public-api}"
        PAYMENT_API_URI = "http://${NOMAD_ADDR_payments-api}"
      }
    }
    
    task "frontend" {
      driver = "docker"
      meta {
        service = "frontend"
      }
      service {
        port     = "frontend"
        tags     = ["hashicups", "frontend"]
        provider = "nomad"
        address      = attr.unique.platform.aws.public-ipv4
      }
      env {
        NEXT_PUBLIC_PUBLIC_API_URL= "/"
        PORT = "${NOMAD_PORT_frontend}"
      }
      config {
        image   = "hashicorpdemoapp/frontend:${var.frontend_version}"
        ports = ["frontend"]
      }
    }

    task "nginx" {
      driver = "docker"
      meta {
        service = "nginx-reverse-proxy"
      }
      service {
        port     = "nginx"
        tags     = ["hashicups", "frontend"]
        provider = "nomad"
        address      = attr.unique.platform.aws.public-ipv4
      }
      config {
        image = "nginx:alpine"
        ports = ["nginx"]
        mount {
          type   = "bind"
          source = "local/default.conf"
          target = "/etc/nginx/conf.d/default.conf"
        }
      }
      template {
        data =  <<EOF
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=STATIC:10m inactive=7d use_temp_path=off;
upstream frontend_upstream {
  server {{ env "NOMAD_IP_nginx" }}:{{ env "NOMAD_PORT_frontend" }};
}
server {
  listen {{ env "NOMAD_PORT_nginx" }};
  server_name {{ env "NOMAD_IP_nginx" }};
  server_tokens off;
  gzip on;
  gzip_proxied any;
  gzip_comp_level 4;
  gzip_types text/css application/javascript image/svg+xml;
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection 'upgrade';
  proxy_set_header Host $host;
  proxy_cache_bypass $http_upgrade;
  location /_next/static {
    proxy_cache STATIC;
    proxy_pass http://frontend_upstream;
    # For testing cache - remove before deploying to production
    add_header X-Cache-Status $upstream_cache_status;
  }
  location /static {
    proxy_cache STATIC;
    proxy_ignore_headers Cache-Control;
    proxy_cache_valid 60m;
    proxy_pass http://frontend_upstream;
    # For testing cache - remove before deploying to production
    add_header X-Cache-Status $upstream_cache_status;
  }
  location / {
    proxy_pass http://frontend_upstream;
  }
  location /api {
    proxy_pass http://{{ env "NOMAD_IP_frontend" }}:{{ env "NOMAD_PORT_public_api" }};
  }
}
        EOF
        destination = "local/default.conf"
      }
    }
  }
}