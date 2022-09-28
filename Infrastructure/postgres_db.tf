locals {
  database = {
    postgres_db_name = "${local.resource_name_prefix}-db"
    version          = "11"
    sku              = "GP_Standard_D2s_v3"
    storage          = 32768
  }
}

resource "azurerm_postgresql_flexible_server" "gtd_postgres_database" {
  name                = local.database.postgres_db_name
  resource_group_name = azurerm_resource_group.gtp_app_rg.name
  location            = local.locations.primary

  administrator_login    = local.secrets.database_user_value
  administrator_password = random_password.gtd_db_password.result
  version                = local.database.version

  storage_mb = local.database.storage
  sku_name   = local.database.sku
  zone       = "1"

  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }
}

resource "azurerm_postgresql_flexible_server_database" "postgresql_db" {
  name      = "app"
  server_id = azurerm_postgresql_flexible_server.gtd_postgres_database.id
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "postgresql_fw_rule_all" {
  name             = "InternetAccess"
  server_id        = azurerm_postgresql_flexible_server.gtd_postgres_database.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}