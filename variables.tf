variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
}

variable "yc_region" {
  description = "Yandex Cloud region"
}

variable "yc_picture" {
  default = "image.png"
}

variable "content_type" {
  default = "image/png"
}

variable "s3_role" {
  default = "storage.editor"
}

variable "s3_service_account_name" {
  default = "s3-sa"
}

variable "s3_bucket_name" {
  default = "akaramyshev-2026-06-26"
}

variable "s3_object_key" {
  default = "akaramyshev-2026-06-26"
}

variable "vpc_network_name" {
  default = "netology-network"
}

variable "subnet_config" {
  default = {
    name  = "public"
    cidr  = ["10.0.0.0/24"]
  }
}

variable "vm_service_account_name" {
  default = "iam-sa"
}

variable "vm_role" {
  default = "editor"
}

variable "instance_group_name" {
  default = "yc-ig"
}

variable "platform_id" {
  default = "standard-v1"
}

variable "instance_user_data_template" {
  default = <<-EOT
    #!/bin/bash
    cd /var/www/html
    echo "<html><head><meta charset=\"utf-8\"><title>Title</title></head><h2>Lab: &#171;Вычислительные мощности. Балансировщики нагрузки&#187;</h2><img src='https://BUCKET_NAME.storage.yandexcloud.net/OBJECT_KEY'></html>" > index.html
  EOT
}

variable "instance_labels" {
  default = "network-load-balanced"
}

variable "target_group_name" {
  default = "target-group"
}

variable "target_group_description" {
  default = "Network Balancer Target Group"
}

variable "yc_lb_name" {
  default = "network-load-balancer-1"
}

variable "lb_listener_name" {
  default = "network-load-balancer-1-listener"
}

variable "lb_ip_version" {
  default = "ipv4"
}

variable "healthcheck_name" {
  default = "http"
}

variable "vm_config" {
  default = {
    memory    = 2,
    cores     = 2,
    image_id  = "fd827b91d99psvq5fjit"
  }
}

variable "http_options" {
  default = {
    port = 80
    path = "/"
  }
}
