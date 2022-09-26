# Create the Linux App Service Plan
resource "azurerm_service_plan" "gtd_app_service_plan" {
  name                = "webapp-asp-gtd"
  location            = azurerm_resource_group.gtp_app_rg.location
  resource_group_name = azurerm_resource_group.gtp_app_rg.name
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_app_service" "gtp_app_service_stamp_1" {
  name                    = "gtd-app-stamp-1"
  location                = azurerm_resource_group.gtp_app_rg.location
  resource_group_name     = azurerm_resource_group.gtp_app_rg.name
  app_service_plan_id     = azurerm_service_plan.gtd_app_service_plan.id
  https_only              = true
  client_affinity_enabled = true

  site_config {
    always_on = "true"

    linux_fx_version  = "DOCKER|servian/techchallengeapp:latest"
    app_command_line  = "serve"
    health_check_path = "/healthcheck"
  }

  app_settings = local.gtd_settings
}

resource "azurerm_app_service" "gtp_app_service_stamp_1" {
  name                    = "gtd-app-stamp-1"
  location                = azurerm_resource_group.gtp_app_rg.location
  resource_group_name     = azurerm_resource_group.gtp_app_rg.name
  app_service_plan_id     = azurerm_service_plan.gtd_app_service_plan.id
  https_only              = true
  client_affinity_enabled = true

  site_config {
    always_on = "true"

    linux_fx_version  = "DOCKER|servian/techchallengeapp:latest"
    app_command_line  = "serve"
    health_check_path = "/healthcheck"
  }

  app_settings = local.gtd_settings
}