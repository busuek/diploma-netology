# === Bastion Host ===
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  zone        = var.zone_a
  platform_id = "standard-v3"

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size         = var.vm_disk_size
      type         = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  scheduling_policy {
    preemptible = false
  }
}

# === Web1 ===
resource "yandex_compute_instance" "web1" {
  name        = "web1"
  hostname    = "web1"
  zone        = var.zone_a
  platform_id = "standard-v3"

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size         = var.vm_disk_size
      type         = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_a.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web_new.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  scheduling_policy {
    preemptible = false
  }
}

# === Web2 ===
resource "yandex_compute_instance" "web2" {
  name        = "web2"
  hostname    = "web2"
  zone        = var.zone_b
  platform_id = "standard-v3"

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size         = var.vm_disk_size
      type         = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_b.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web_new.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  scheduling_policy {
    preemptible = false
  }
}

# === Zabbix ===
resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix"
  hostname    = "zabbix"
  zone        = var.zone_a
  platform_id = "standard-v3"

  resources {
    cores         = var.vm_cores
    memory        = 4
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size         = var.vm_disk_size
      type         = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.zabbix.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  scheduling_policy {
    preemptible = false
  }
}

# === Elasticsearch ===
resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch"
  hostname    = "elasticsearch"
  zone        = var.zone_a
  platform_id = "standard-v3"

  resources {
    cores         = var.vm_cores
    memory        = 4
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size         = var.vm_disk_size
      type         = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_es.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.elasticsearch.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  scheduling_policy {
    preemptible = false
  }
}

# === Kibana ===
resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  hostname    = "kibana"
  zone        = var.zone_a
  platform_id = "standard-v3"

  resources {
    cores         = var.vm_cores
    memory        = 4
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size         = var.vm_disk_size
      type         = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kibana.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  scheduling_policy {
    preemptible = false
  }
}
