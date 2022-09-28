locals {
  resource_name_prefix = "gtd-app"
  resource_group_name  = "rg-${local.resource_name_prefix}"
  locations = {
    primary   = "Central US"
    secondary = "East US"
  }
}