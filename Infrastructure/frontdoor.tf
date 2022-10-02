locals {
  frontdoor = {
    name              = "${local.resource_name_prefix}-fd-123123"
    frontend          = "${local.resource_name_prefix}-servian"
    backend_pool_name = "${local.resource_name_prefix}-services"
    routing_rule_name = "${local.resource_name_prefix}-location-rule"
  }
}

resource "azurerm_frontdoor" "gtd-app-fd" {
  name                = local.frontdoor.frontend
  resource_group_name = azurerm_resource_group.gtp_app_rg.name

  frontend_endpoint {
    name                         = local.frontdoor.frontend
    host_name                    = "${local.frontdoor.frontend}.azurefd.net"
    session_affinity_enabled     = false
    session_affinity_ttl_seconds = 0
  }

  routing_rule {
    name               = local.frontdoor.routing_rule_name
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [local.frontdoor.frontend]

    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"
      backend_pool_name   = local.frontdoor.backend_pool_name
    }
  }

  backend_pool_load_balancing {
    name = "LoadBalancingSetting"
  }

  backend_pool_health_probe {
    name     = "HealthProbeSetting"
    protocol = "Https"
    path     = local.app_services.health_check_path
  }

  backend_pool {
    name = local.frontdoor.backend_pool_name

    backend {
      host_header = "${azurerm_linux_web_app.gtp_app_service_stamp_1.name}.azurewebsites.net"
      address     = "${azurerm_linux_web_app.gtp_app_service_stamp_1.name}.azurewebsites.net"
      http_port   = 80
      https_port  = 443
    }

    backend {
      host_header = "${azurerm_linux_web_app.gtp_app_service_stamp_2.name}.azurewebsites.net"
      address     = "${azurerm_linux_web_app.gtp_app_service_stamp_2.name}.azurewebsites.net"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "LoadBalancingSetting"
    health_probe_name   = "HealthProbeSetting"
  }
}