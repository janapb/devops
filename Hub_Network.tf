
# Create a resource group
resource "azurerm_resource_group" "poc_rg" {
  name     = var.rg_name
  location = var.location
  tags     = var.comman_tags
}

