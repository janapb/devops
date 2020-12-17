
# Create a resource group
resource "azurerm_resource_group" "poc_rg" {
  name     = var.rg_name
  location = var.location
  tags     = var.comman_tags
}

# Creates the Hub VNET
resource "azurerm_virtual_network" "poc_mgmt_vnet" {
  name                = var.mgmt_vnet_name
  location            = azurerm_resource_group.poc_rg.location
  resource_group_name = azurerm_resource_group.poc_rg.name
  address_space       = [var.mgmt_vnet_cidr]
  tags                = var.comman_tags
}

# Creates subnet of Hub Network
resource "azurerm_subnet" "hub_subnet" {
  count                = length(var.subnet_prefix)
  name                 = lookup(element(var.subnet_prefix, count.index), "name")
  resource_group_name  = azurerm_resource_group.poc_rg.name
  virtual_network_name = azurerm_virtual_network.poc_mgmt_vnet.name
  address_prefix       = lookup(element(var.subnet_prefix, count.index), "ip")
}


# Creates Network Security Group For Hub subnet 
resource "azurerm_network_security_group" "nsg-hub" {
  count               = length(var.subnet_prefix)
  name                = "${lookup(element(var.subnet_prefix, count.index), "name")}-NSG"
  location            = azurerm_resource_group.poc_rg.location
  resource_group_name = azurerm_resource_group.poc_rg.name
  tags                = var.comman_tags
}

# Associates jumpbox Network Security Group to subnet within Hub Network
resource "azurerm_subnet_network_security_group_association" "hub-asso-nsg" {
  count                     = length(var.subnet_prefix)
  subnet_id                 = azurerm_subnet.hub_subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg-hub[count.index].id
}
