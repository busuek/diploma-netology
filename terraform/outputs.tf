# === IP-адреса всех ВМ ===

output "bastion_external_ip" {
  description = "Bastion external IP"
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "bastion_internal_ip" {
  description = "Bastion internal IP"
  value       = yandex_compute_instance.bastion.network_interface[0].ip_address
}

output "web1_internal_ip" {
  description = "Web1 internal IP"
  value       = yandex_compute_instance.web1.network_interface[0].ip_address
}

output "web2_internal_ip" {
  description = "Web2 internal IP"
  value       = yandex_compute_instance.web2.network_interface[0].ip_address
}

output "zabbix_external_ip" {
  description = "Zabbix external IP"
  value       = yandex_compute_instance.zabbix.network_interface[0].nat_ip_address
}

output "elasticsearch_internal_ip" {
  description = "Elasticsearch internal IP"
  value       = yandex_compute_instance.elasticsearch.network_interface[0].ip_address
}

output "kibana_external_ip" {
  description = "Kibana external IP"
  value       = yandex_compute_instance.kibana.network_interface[0].nat_ip_address
}

# === FQDN для Ansible inventory ===

output "all_fqdn" {
  description = "FQDN of all VMs"
  value = {
    bastion       = "${yandex_compute_instance.bastion.hostname}.ru-central1.internal"
    web1          = "${yandex_compute_instance.web1.hostname}.ru-central1.internal"
    web2          = "${yandex_compute_instance.web2.hostname}.ru-central1.internal"
    zabbix        = "${yandex_compute_instance.zabbix.hostname}.ru-central1.internal"
    elasticsearch = "${yandex_compute_instance.elasticsearch.hostname}.ru-central1.internal"
    kibana        = "${yandex_compute_instance.kibana.hostname}.ru-central1.internal"
  }
}
