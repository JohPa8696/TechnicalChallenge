locals {
  database = {
    postgres_server_name   = "${local.resource_name_prefix}-server"
    version                = "11"
    sku                    = "GP_Standard_D2s_v3"
    storage                = 32768
    name                   = "app"
    user                   = "servian"
    high_availability_mode = "ZoneRedundant"
  }
}

resource "azurerm_postgresql_flexible_server" "postgres_server" {
  name                = local.database.postgres_server_name
  resource_group_name = azurerm_resource_group.gtp_app_rg.name
  location            = local.locations.primary

  administrator_login    = local.database.user
  administrator_password = random_password.gtd_db_password.result
  version                = local.database.version

  storage_mb = local.database.storage
  sku_name   = local.database.sku
  zone       = "1"

  high_availability {
    mode                      = local.database.high_availability_mode
    standby_availability_zone = "2"
  }
}

resource "azurerm_postgresql_flexible_server_database" "postgres_gtd_db" {
  name      = local.database.name
  server_id = azurerm_postgresql_flexible_server.postgres_server.id
}

resource "azurerm_postgresql_flexible_server_configuration" "postgres_gtd_server_ssl_off" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.postgres_server.id
  value     = "off"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "postgres_gtd_server_fw_rule_app_services_ips" {
  for_each         = toset(distinct(concat(azurerm_linux_web_app.gtp_app_service_stamp_1.outbound_ip_address_list, azurerm_linux_web_app.gtp_app_service_stamp_2.outbound_ip_address_list)))
  name             = "Allow_${replace(each.key, ".", "")}"
  server_id        = azurerm_postgresql_flexible_server.postgres_server.id
  start_ip_address = each.key
  end_ip_address   = each.key
}

