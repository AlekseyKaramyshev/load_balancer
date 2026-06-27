resource "yandex_iam_service_account" "s3-sa" {
  name        = var.s3_service_account_name
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.yc_folder_id
  role      = var.s3_role
  member    = "serviceAccount:${yandex_iam_service_account.s3-sa.id}"

  depends_on = [
    yandex_iam_service_account.s3-sa
  ]
}

resource "yandex_iam_service_account_static_access_key" "sa-key" {
  service_account_id = yandex_iam_service_account.s3-sa.id
}

resource "yandex_storage_bucket" "s3-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-key.secret_key
  bucket     = var.s3_bucket_name
  max_size = 1073741824 # 1 Gb
  anonymous_access_flags {
    read = true
    list = false
  }

  depends_on = [
    yandex_iam_service_account_static_access_key.sa-key,
    yandex_resourcemanager_folder_iam_member.sa-editor
  ]
}

resource "yandex_storage_object" "s3-image" {
  access_key = yandex_iam_service_account_static_access_key.sa-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-key.secret_key
  bucket     = yandex_storage_bucket.s3-bucket.id
  key        = var.s3_object_key
  source     = var.yc_picture
  content_type = var.content_type

  depends_on = [
    yandex_storage_bucket.s3-bucket
  ]
}

resource "yandex_vpc_network" "netology-network" {
  name = var.vpc_network_name
}

resource "yandex_vpc_subnet" "public" {
  name           = var.subnet_config.name
  v4_cidr_blocks = var.subnet_config.cidr
  zone           = var.yc_region
  network_id     = yandex_vpc_network.netology-network.id

  depends_on = [
    yandex_vpc_network.netology-network
  ]
}

resource "yandex_iam_service_account" "iam-sa" {
  name        = var.vm_service_account_name
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.yc_folder_id
  role      = var.vm_role
  member    = "serviceAccount:${yandex_iam_service_account.iam-sa.id}"

  depends_on = [
    yandex_iam_service_account.iam-sa
  ]
}

resource "yandex_compute_instance_group" "yc-ig" {
  name               = var.instance_group_name
  folder_id          = var.yc_folder_id
  service_account_id = yandex_iam_service_account.iam-sa.id
  instance_template {
    platform_id = var.platform_id
    resources {
      memory = var.vm_config.memory
      cores  = var.vm_config.cores
    }

    boot_disk {
      initialize_params {
        image_id = var.vm_config.image_id
      }
    }

    network_interface {
      network_id = yandex_vpc_network.netology-network.id
      subnet_ids = [yandex_vpc_subnet.public.id]
    }

    metadata = {
      ssh-keys  = "ubuntu:${file("~/.ssh/id_ed25519_lbg_temp.pub")}"
      user-data = local.instance_user_data
    }
    labels = {
      group = var.instance_labels
    }

    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.yc_region]
  }

  deploy_policy {
    max_unavailable = 2
    max_expansion   = 1
  }

  health_check {
    interval            = 2
    timeout             = 1
    healthy_threshold   = 5
    unhealthy_threshold = 2
    http_options {
      port = var.http_options.port
      path = var.http_options.path
    }
  }

  load_balancer {
    target_group_name        = var.target_group_name
    target_group_description = var.target_group_description
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.editor,
    yandex_vpc_subnet.public,
    yandex_storage_bucket.s3-bucket,
    yandex_storage_object.s3-image
  ]
}

resource "yandex_lb_network_load_balancer" "yc_nlb" {
  name = var.yc_lb_name

  listener {
    name = var.lb_listener_name
    port = 80
    external_address_spec {
      ip_version = var.lb_ip_version
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.yc-ig.load_balancer.0.target_group_id

    healthcheck {
      name                  = var.healthcheck_name
      interval              = 2
      timeout               = 1
      unhealthy_threshold   = 2
      healthy_threshold     = 5
      http_options {
        port = var.http_options.port
        path = var.http_options.path
      }
    }
  }
}
