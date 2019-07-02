variable "app" {}
variable "service_name" {}
variable "image" {}
variable "container_port" {}
variable "replicas" {}

variable "ebmeds-configuration" {}
variable "ebmeds-quay-secret" {}
variable "users-configuration" {}

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
          command = ["sh", "-c", "until wget -O- http://engine:3002/status; do echo waiting for engine; sleep 2; done"]
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
          volume_mount {
            mount_path = "/app/resource/users.json"
            name = "users-volume"
            sub_path = "users.json"
          }
        }
        volume {
          name = "users-volume"
          config_map {
            name = "users-configuration"
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

resource "kubernetes_service" "api-gateway-service" {
  metadata {
    name = "${var.service_name}"
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
      node_port = var.container_port
    }
    # FIXME: currently LoadBalancer type is not working with the terraform
    # FIXME: when using minikube kluster
    type = "NodePort"
  }
}

# FIXME: does not display output
output "api-gateway-ip" {
  value = kubernetes_service.api-gateway-service
}
