# === SG для Bastion ===
resource "yandex_vpc_security_group" "bastion" {
  name        = "sg-bastion"
  description = "Security group for bastion host"
  network_id  = data.yandex_vpc_network.diploma.id

  ingress {
    description    = "SSH from internet"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Outgoing to private networks"
    protocol       = "ANY"
    v4_cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    description    = "Outgoing to internet"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# === SG для Web-серверов ===
resource "yandex_vpc_security_group" "web_new" {
  name        = "sg-web-new"
  description = "Security group for web servers"
  network_id  = data.yandex_vpc_network.diploma.id

  ingress {
    description    = "HTTP from load balancer"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description    = "SSH from bastion subnet"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["10.1.0.0/24"]
  }

  ingress {
    description    = "Zabbix agent from zabbix server"
    protocol       = "TCP"
    port           = 10050
    v4_cidr_blocks = ["10.1.0.0/24"]
  }

  egress {
    description    = "Outgoing all"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# === SG для Zabbix ===
resource "yandex_vpc_security_group" "zabbix" {
  name        = "sg-zabbix"
  description = "Security group for Zabbix server"
  network_id  = data.yandex_vpc_network.diploma.id

  ingress {
    description    = "Web access"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Zabbix agent"
    protocol       = "TCP"
    port           = 10050
    v4_cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description    = "Zabbix trapper"
    protocol       = "TCP"
    port           = 10051
    v4_cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    description    = "Outgoing all"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# === SG для Elasticsearch ===
resource "yandex_vpc_security_group" "elasticsearch" {
  name        = "sg-elasticsearch"
  description = "Security group for Elasticsearch"
  network_id  = data.yandex_vpc_network.diploma.id

  ingress {
    description    = "Elasticsearch from internal"
    protocol       = "TCP"
    port           = 9200
    v4_cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description    = "SSH from bastion subnet"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["10.1.0.0/24"]
  }

  egress {
    description    = "Outgoing all"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# === SG для Kibana ===
resource "yandex_vpc_security_group" "kibana" {
  name        = "sg-kibana"
  description = "Security group for Kibana"
  network_id  = data.yandex_vpc_network.diploma.id

  ingress {
    description    = "Web access"
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Outgoing all"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
