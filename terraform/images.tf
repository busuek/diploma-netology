# Получаем ID образа Ubuntu 22.04 LTS по семейству
data "yandex_compute_image" "ubuntu" {
  family = var.vm_image_family
}
