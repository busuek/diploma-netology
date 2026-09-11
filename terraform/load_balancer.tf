# === Target Group ===
resource "yandex_alb_target_group" "web" {
  name = "web-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.private_a.id
    ip_address = yandex_compute_instance.web1.network_interface[0].ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.private_b.id
    ip_address = yandex_compute_instance.web2.network_interface[0].ip_address
  }
}

# === Backend Group ===
resource "yandex_alb_backend_group" "web" {
  name = "web-backend-group"

  http_backend {
    name             = "web-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web.id]

    healthcheck {
      timeout  = "5s"
      interval = "10s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# === HTTP Router ===
resource "yandex_alb_http_router" "web" {
  name = "web-http-router"
}

resource "yandex_alb_virtual_host" "web" {
  name           = "web-virtual-host"
  http_router_id = yandex_alb_http_router.web.id

  route {
    name = "web-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
      }
    }
  }
}

# === Application Load Balancer ===
resource "yandex_alb_load_balancer" "web" {
  name        = "web-load-balancer"
  network_id  = data.yandex_vpc_network.diploma.id
  security_group_ids = [yandex_vpc_security_group.web_new.id]

  allocation_policy {
    location {
      zone_id   = var.zone_a
      subnet_id = yandex_vpc_subnet.public_a.id
    }
  }

  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }
}

# === Output ===
output "load_balancer_ip" {
  value = yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}
