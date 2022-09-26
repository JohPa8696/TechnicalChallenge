# Create a resource group
resource "azurerm_resource_group" "gtp_app_rg" {
  name     = "rg-gtp-app"
  location = "Central US"
}