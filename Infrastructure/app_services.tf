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
    docker_serve_command    = "serve"
    docker_seed_command     = "updatedb -s"
    health_check_path       = "/healthcheck"
  }

  app_services_settings = {
    listen_host = "0.0.0.0"
    listen_port = 80
    db_port     = "5432"
    db_type     = "postgres"
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
    app_command_line  = local.app_services.docker_serve_command
    health_check_path = local.app_services.health_check_path

    ip_restriction {
      name        = "Access_via_frontdoor"
      action      = "Allow"
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.gtd_app_service_identity.id]
  }

  key_vault_reference_identity_id = azurerm_user_assigned_identity.gtd_app_service_identity.id

  app_settings = {
    VTT_LISTENHOST = local.app_services_settings.listen_host
    VTT_LISTENPORT = local.app_services_settings.listen_port
    VTT_DBHOST     = azurerm_postgresql_flexible_server.postgres_server.fqdn
    VTT_DBPORT     = local.app_services_settings.db_port
    VTT_DBNAME     = local.database.name
    VTT_DBTYPE     = local.app_services_settings.db_type
    VTT_DBUSER     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.gtd_db_user.id})"
    VTT_DBPASSWORD = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.gtd_db_user_password.id})"
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
    app_command_line  = local.app_services.docker_serve_command
    health_check_path = local.app_services.health_check_path

    ip_restriction {
      name        = "Access_via_frontdoor"
      action      = "Allow"
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.gtd_app_service_identity.id]
  }

  key_vault_reference_identity_id = azurerm_user_assigned_identity.gtd_app_service_identity.id

  app_settings = {
    VTT_LISTENHOST = local.app_services_settings.listen_host
    VTT_LISTENPORT = local.app_services_settings.listen_port
    VTT_DBHOST     = azurerm_postgresql_flexible_server.postgres_server.fqdn
    VTT_DBPORT     = local.app_services_settings.db_port
    VTT_DBNAME     = local.database.name
    VTT_DBTYPE     = local.app_services_settings.db_type
    VTT_DBUSER     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.gtd_db_user.id})"
    VTT_DBPASSWORD = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.gtd_db_user_password.id})"
  }
}


data "template_file" "gtd_seed_data_for_db" {
  template = file("./scripts/seed_data.ps1.tpl")
  vars = {
    subscription_id     = var.subscription_id
    tenant_id           = var.tenant_id
    client_id           = var.client_id
    client_secret       = var.client_secret
    resource_name       = azurerm_linux_web_app.gtp_app_service_stamp_1.name
    resource_group_name = azurerm_resource_group.gtp_app_rg.name
    seed_command        = local.app_services.docker_seed_command
    serve_command       = local.app_services.docker_serve_command
  }
}

resource "null_resource" "gtd_seed_data" {
  provisioner "local-exec" {
    command     = data.template_file.gtd_seed_data_for_db.rendered
    interpreter = ["PowerShell", "-Command"]
  }
  depends_on = [
    azurerm_postgresql_flexible_server_firewall_rule.postgres_gtd_server_fw_rule_app_services_ips
  ]
}