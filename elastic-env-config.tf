resource "kubernetes_config_map" "elastic-env-configuration" {
  metadata {
    name = "elastic-stack-configuration"
    labels = {
      app = var.app
      name = "elastic-stack-configuration"
    }
  }
  data = {
    # set the below values to 50% of your server RAM, and for best performance
    # turn off swapping on the host OS
    ES_JAVA_OPTS = "-Xms2g -Xmx2g"

    # Logstash memory limits, should be fine for most deployments
    LS_JAVA_OPTS = "-Xmx256m -Xms256m"
  }
}
