variable "app" {}
variable "service_name" {}
variable "image" {}
variable "container_port" {}
variable "replicas" {}

variable "ebmeds-configuration" {}
variable "ebmeds-quay-secret" {}
variable "init-helper-command" {
  default = ["echo"]
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name = var.service_name
    labels = {
      app = var.app
      name = "${var.service_name}-deployment"
    }
  }

  spec {
    template {
      metadata {
        name = var.service_name
        labels = {
          app = var.app
          name = var.service_name
        }
      }
      spec {
        init_container {
          name = "init-helper"
          image = "busybox"
          command = var.init-helper-command
        }
        container {
          name = var.service_name
          image = var.image
          port {
            container_port = var.container_port
          }
          env_from {
            config_map_ref {
              name = var.ebmeds-configuration
            }
          }
        }
        image_pull_secrets {
          name = var.ebmeds-quay-secret
        }
      }
    }
    replicas = var.replicas
    selector {
      match_labels = {
        app = var.app
        name = var.service_name
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name = var.service_name
    labels = {
      app = var.app
      name = "${var.service_name}-service"
    }
  }
  spec {
    selector = {
      app = var.app
      name = var.service_name
    }
    port {
      port = var.container_port
      target_port = var.container_port
    }
    type = "ClusterIP"
  }
}
