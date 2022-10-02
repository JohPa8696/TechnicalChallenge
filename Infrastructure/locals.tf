locals {
  resource_name_prefix = "gtd-app"
  resource_group_name  = "rg-${local.resource_name_prefix}"

  resource_group_tags = {
    environment = "dev"
    cost_center = "dev"
  }

  locations = {
    primary   = "Central US"
    secondary = "East US"
  }
}