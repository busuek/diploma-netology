# Используем существующую сеть default (квота на создание новых исчерпана)
data "yandex_vpc_network" "diploma" {
  name = "default"
}

# Публичная подсеть (зона A) — bastion, zabbix, kibana
resource "yandex_vpc_subnet" "public_a" {
  name           = "public-subnet-a"
  zone           = var.zone_a
  network_id     = data.yandex_vpc_network.diploma.id
  v4_cidr_blocks = ["10.1.0.0/24"]
}

# Приватная подсеть (зона A) — web1
resource "yandex_vpc_subnet" "private_a" {
  name           = "private-subnet-a"
  zone           = var.zone_a
  network_id     = data.yandex_vpc_network.diploma.id
  v4_cidr_blocks = ["10.2.0.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

# Приватная подсеть (зона B) — web2
resource "yandex_vpc_subnet" "private_b" {
  name           = "private-subnet-b"
  zone           = var.zone_b
  network_id     = data.yandex_vpc_network.diploma.id
  v4_cidr_blocks = ["10.3.0.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

# Приватная подсеть (зона A) — elasticsearch
resource "yandex_vpc_subnet" "private_es" {
  name           = "private-subnet-es"
  zone           = var.zone_a
  network_id     = data.yandex_vpc_network.diploma.id
  v4_cidr_blocks = ["10.4.0.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

# NAT-шлюз для доступа приватных ВМ в интернет
resource "yandex_vpc_gateway" "nat" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

# Route table для приватных подсетей — весь трафик через NAT
resource "yandex_vpc_route_table" "private" {
  name       = "route-private"
  network_id = data.yandex_vpc_network.diploma.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}
