locals {
  app_services = {
    app_service_plan_name_1 = "${local.resource_name_prefix}-plan-1"
    app_service_plan_name_2 = "${local.resource_name_prefix}-plan-2"
    app_service_stamp_1     = "${local.resource_name_prefix}-stamp-1"
    app_service_stamp_2     = "${local.resource_name_prefix}-stamp-2"
    os                      = "Linux"
    sku                     = "P1v2"
    docker_image            = "servian/techchallengeapp"
    docker_image_tag        = "latest"
    docker_command          = "serve"
  }
}

#-------------------------------------------------
# App Service - Stamp 1
#-------------------------------------------------
resource "azurerm_service_plan" "gtd_app_service_plan_1" {
  name                = local.app_services.app_service_plan_name_1
  location            = local.locations.primary
  resource_group_name = azurerm_resource_group.gtp_app_rg.name
  os_type             = local.app_services.os
  sku_name            = local.app_services.sku
}

resource "azurerm_linux_web_app" "gtp_app_service_stamp_1" {
  name                = local.app_services.app_service_stamp_1
  location            = azurerm_resource_group.gtp_app_rg.location
  resource_group_name = azurerm_resource_group.gtp_app_rg.name
  service_plan_id     = azurerm_service_plan.gtd_app_service_plan_1.id
  https_only          = true

  site_config {
    always_on = "true"

    application_stack {
      docker_image     = local.app_services.docker_image
      docker_image_tag = local.app_services.docker_image_tag
    }
    app_command_line  = local.app_services.docker_command
    health_check_path = "/healthcheck"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.gtd_app_service_identity.id]
  }

  key_vault_reference_identity_id = azurerm_user_assigned_identity.gtd_app_service_identity.id

  app_settings = {
    VTT_LISTENHOST = "0.0.0.0"
    VTT_LISTENPORT = 80
    VTT_DBHOST     = azurerm_postgresql_flexible_server.gtd_postgres_database.fqdn
    VTT_DBPORT     = "5432"
    VTT_DBNAME     = "app"
    VTT_DBUSER     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.gtd_db_user.id})"
    VTT_PASSWORD   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.gtd_db_user_password.id})"
  }
}

#-------------------------------------------------
# App Service - Stamp 2 
#-------------------------------------------------
resource "azurerm_service_plan" "gtd_app_service_plan_2" {
  name                = local.app_services.app_service_plan_name_2
  location            = local.locations.secondary
  resource_group_name = azurerm_resource_group.gtp_app_rg.name
  os_type             = local.app_services.os
  sku_name            = local.app_services.sku
}

resource "azurerm_linux_web_app" "gtp_app_service_stamp_2" {
  name                = local.app_services.app_service_stamp_2
  location            = local.locations.secondary
  resource_group_name = azurerm_resource_group.gtp_app_rg.name
  service_plan_id     = azurerm_service_plan.gtd_app_service_plan_2.id
  https_only          = true

  site_config {
    always_on = "true"

    application_stack {
      docker_image     = local.app_services.docker_image
      docker_image_tag = local.app_services.docker_image_tag
    }
    app_command_line  = local.app_services.docker_command
    health_check_path = "/healthcheck"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.gtd_app_service_identity.id]
  }

  key_vault_reference_identity_id = azurerm_user_assigned_identity.gtd_app_service_identity.id

  app_settings = {
    VTT_LISTENHOST = "0.0.0.0"
    VTT_LISTENPORT = 80
    VTT_DBHOST     = azurerm_postgresql_flexible_server.gtd_postgres_database.fqdn
    VTT_DBPORT     = "5432"
    VTT_DBNAME     = "app"
    VTT_DBUSER     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.gtd_db_user.id})"
    VTT_PASSWORD   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.gtd_db_user_password.id})"
  }
}