provider "kubernetes" {
  version = "~> 1.7"
}

resource "kubernetes_secret" "ebmeds-quay-secret" {
  metadata {
    name = var.ebmeds-quay-secret
    labels = {
      app = var.app
      name = var.ebmeds-quay-secret
    }
  }
  data = {
    ".dockerconfigjson" = file(pathexpand("~/.docker/config.json"))
  }
  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_config_map" "users-configuration" {
  metadata {
    name = var.users-configuration
    labels = {
      app = var.app
      name = var.users-configuration
    }
  }
  data = {
    "users.json" = file("${path.module}/users.json")
  }
}

module "api-gateway" {
  source = "./load-balancer"

  app = var.app
  service_name = "api-gateway"
  image = "quay.io/duodecim/ebmeds-api-gateway:${var.ebmeds-version}"
  container_port = 3001
  replicas = 2
  ebmeds-quay-secret = var.ebmeds-quay-secret
  ebmeds-configuration = var.ebmeds-configuration
  users-configuration = var.users-configuration
}

module "engine" {
  source = "./ebmeds"

  app = var.app
  service_name = "engine"
  image = "quay.io/duodecim/ebmeds-engine:${var.ebmeds-version}"
  container_port = 3002
  replicas = var.replicas
  ebmeds-quay-secret = var.ebmeds-quay-secret
  ebmeds-configuration = var.ebmeds-configuration
  init-helper-command = ["sh", "-c", "until wget -O- http://clinical-datastore:3004/status; do echo waiting for clinical-datastore; sleep 2; done;"]
}

module "clinical-datastore" {
  source = "./ebmeds"

  app = var.app
  service_name = "clinical-datastore"
  image = "quay.io/duodecim/ebmeds-clinical-datastore:${var.ebmeds-version}"
  container_port = 3004
  replicas = var.replicas
  ebmeds-quay-secret = var.ebmeds-quay-secret
  ebmeds-configuration = var.ebmeds-configuration
}

module "format-converter" {
  source = "./ebmeds"

  app = var.app
  service_name = "format-converter"
  image = "quay.io/duodecim/ebmeds-format-converter:${var.ebmeds-version}"
  container_port = 3005
  replicas = var.replicas
  ebmeds-quay-secret = var.ebmeds-quay-secret
  ebmeds-configuration = var.ebmeds-configuration
}

module "caregap" {
  source = "./ebmeds"

  app = var.app
  service_name = "caregap"
  image = "quay.io/duodecim/ebmeds-caregap:${var.ebmeds-version}"
  container_port = 3006
  replicas = var.replicas
  ebmeds-quay-secret = var.ebmeds-quay-secret
  ebmeds-configuration = var.ebmeds-configuration
}
