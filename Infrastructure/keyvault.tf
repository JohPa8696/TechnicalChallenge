locals {
  keyvault = {
    name = "${local.resource_name_prefix}-kv-1"
    sku  = "standard"
  }

  secrets = {
    database_user_secret          = "${local.resource_name_prefix}-db-user"
    database_user_value           = "servian"
    database_user_password_secret = "${local.resource_name_prefix}-db-user-password"
  }
}

resource "azurerm_key_vault" "gtd_keyvault" {
  name = local.keyvault.name

  location            = local.locations.primary
  resource_group_name = azurerm_resource_group.gtp_app_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = local.keyvault.sku
}

resource "azurerm_key_vault_access_policy" "principal" {
  key_vault_id = azurerm_key_vault.gtd_keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}

resource "azurerm_key_vault_access_policy" "gtd_app_service_kv_access" {
  key_vault_id = azurerm_key_vault.gtd_keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.gtd_app_service_identity.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_secret" "gtd_db_user" {
  name  = local.secrets.database_user_secret
  value = local.secrets.database_user_value

  key_vault_id = azurerm_key_vault.gtd_keyvault.id

  depends_on = [
    azurerm_key_vault_access_policy.principal
  ]
}

resource "azurerm_key_vault_secret" "gtd_db_user_password" {
  name  = local.secrets.database_user_password_secret
  value = random_password.gtd_db_password.result

  key_vault_id = azurerm_key_vault.gtd_keyvault.id

  depends_on = [
    azurerm_key_vault_access_policy.principal
  ]
}