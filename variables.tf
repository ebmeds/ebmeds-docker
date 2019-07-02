variable "ebmeds-version" {
  default = "latest"
}

variable "app" {
  default = "ebmeds"
}

variable "ebmeds-quay-secret" {
  default = "ebmeds-quay-secret"
}

variable "ebmeds-configuration" {
  default = "ebmeds-configuration"
}

variable "users-configuration" {
  default = "users-configuration"
}

variable "replicas" {
  default = 1
}

variable "elastic-version" {
  default = "7.2.0"
}
