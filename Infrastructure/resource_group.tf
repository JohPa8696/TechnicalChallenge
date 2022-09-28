# Create a resource group
resource "azurerm_resource_group" "gtp_app_rg" {
  name     = local.resource_group_name
  location = local.locations.primary
}