# Yandex Cloud
variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone_a" {
  description = "Availability zone A"
  type        = string
  default     = "ru-central1-a"
}

variable "zone_b" {
  description = "Availability zone B"
  type        = string
  default     = "ru-central1-b"
}

# SSH
variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# Настройки ВМ
variable "vm_cores" {
  description = "Number of CPU cores for VMs"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Memory in GB for VMs"
  type        = number
  default     = 2
}

variable "vm_core_fraction" {
  description = "Core fraction for VMs"
  type        = number
  default     = 20
}

variable "vm_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 10
}

# Образ ОС
variable "vm_image_family" {
  description = "OS image family"
  type        = string
  default     = "ubuntu-2204-lts"
}


variable "service_account_key_file" {
  description = "Path to service account key file"
  type        = string
  default     = "key.json"
}
