locals {
  user_assigned_identity = {
    name = "${local.resource_name_prefix}-services-identity"
  }
}

resource "azurerm_user_assigned_identity" "gtd_app_service_identity" {
  name = local.user_assigned_identity.name

  resource_group_name = azurerm_resource_group.gtp_app_rg.name
  location            = local.locations.primary
}