resource "kubernetes_config_map" "ebmeds-env-configuration" {
  metadata {
    name = var.ebmeds-configuration
    labels = {
      app = var.app
      name = var.ebmeds-configuration
    }
  }
  data = {
    # Set this to whatever URL you will be hosting EBMEDS on. Deprecated, use EBMEDS_API_URL instead
    EBMEDS_CAREGAP_API_URL = null

    EBMEDS_LOG_CAREGAP = "no"

    # Set this to whatever URL you will be hosting EBMEDS on, e.g. http://example.com/ebmeds or https://example.com:3001
    EBMEDS_API_URL = null

    # The log level for internal services, can be debug, info, warn, error
    EBMEDS_LOG_LEVEL = "trace"

    # Set to cluster if wanted (extra configuration also required)
    EBMEDS_REDIS_MODE = "test"

    EBMEDS_LOG_METHODS = "stdout"

    # Determine whether the performance metrics are collected
    # from api-gateway, engine, clinical-datastore and format-converter or not.
    ELASTIC_APM_ACTIVE=false
  }
}
