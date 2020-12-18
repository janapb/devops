
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

# Creates the Spoke management VNET
resource "azurerm_virtual_network" "poc_spoke_vnet" {
  count               = length(var.spoke_vnet_name)
  name                = var.spoke_vnet_name[count.index]
  location            = azurerm_resource_group.poc_rg.location
  resource_group_name = azurerm_resource_group.poc_rg.name
  address_space       = [var.spoke_vnet_cidr[count.index]]
  tags                = var.comman_tags
}

# Creates subnet of Spoke Network
resource "azurerm_subnet" "spoke_subnet" {
  count                = length(var.spoke_subnet_prefix)
  name                 = lookup(element(var.spoke_subnet_prefix, count.index), "name")
  resource_group_name  = azurerm_resource_group.poc_rg.name
  virtual_network_name = azurerm_virtual_network.poc_spoke_vnet[0].name
  address_prefix       = lookup(element(var.spoke_subnet_prefix, count.index), "ip")
}

# Creates Network Security Group For Spoke subnet 
resource "azurerm_network_security_group" "nsg-spoke" {
  count               = length(var.spoke_subnet_prefix)
  name                = "${lookup(element(var.spoke_subnet_prefix, count.index), "name")}-NSG"
  location            = azurerm_resource_group.poc_rg.location
  resource_group_name = azurerm_resource_group.poc_rg.name
  tags                = var.comman_tags
}

# Associates jumpbox Network Security Group to subnet within Hub Network
resource "azurerm_subnet_network_security_group_association" "spoke-asso-nsg" {
  count                     = length(var.spoke_subnet_prefix)
  subnet_id                 = azurerm_subnet.spoke_subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg-spoke[count.index].id
}

locals {
  security_group_rules = csvdecode(file("rules.csv"))
}

resource "azurerm_network_security_rule" "nsg" {
  count                       = length(local.security_group_rules)
  name                        = "${local.security_group_rules[count.index].name}-${count.index}"
  priority                    = local.security_group_rules[count.index].priority
  direction                   = local.security_group_rules[count.index].direction
  access                      = local.security_group_rules[count.index].access
  protocol                    = local.security_group_rules[count.index].protocol
  source_port_range           = local.security_group_rules[count.index].source_port
  destination_port_range      = local.security_group_rules[count.index].destination_port
  source_address_prefix       = local.security_group_rules[count.index].source_address_prefix
  destination_address_prefix  = local.security_group_rules[count.index].destination_address_prefix
  resource_group_name         = azurerm_resource_group.poc_rg.name
  network_security_group_name = azurerm_network_security_group.nsg-hub[1].name
}


locals {
  app_security_group_rules = csvdecode(file("apprules.csv"))
}

resource "azurerm_network_security_rule" "apg-nsg-rules" {
  count                       = length(local.app_security_group_rules)
  name                        = "${local.app_security_group_rules[count.index].name}-${count.index}"
  priority                    = local.app_security_group_rules[count.index].priority
  direction                   = local.app_security_group_rules[count.index].direction
  access                      = local.app_security_group_rules[count.index].access
  protocol                    = local.app_security_group_rules[count.index].protocol
  source_port_range           = local.app_security_group_rules[count.index].source_port
  destination_port_range      = local.app_security_group_rules[count.index].destination_port
  source_address_prefix       = local.app_security_group_rules[count.index].source_address_prefix
  destination_address_prefix  = local.app_security_group_rules[count.index].destination_address_prefix
  resource_group_name         = azurerm_resource_group.poc_rg.name
  network_security_group_name = azurerm_network_security_group.nsg-spoke[0].name
}

locals {
  db_security_group_rules = csvdecode(file("dbrules.csv"))
}

resource "azurerm_network_security_rule" "db-nsg-rules" {
  count                       = length(local.db_security_group_rules)
  name                        = "${local.db_security_group_rules[count.index].name}-${count.index}"
  priority                    = local.db_security_group_rules[count.index].priority
  direction                   = local.db_security_group_rules[count.index].direction
  access                      = local.db_security_group_rules[count.index].access
  protocol                    = local.db_security_group_rules[count.index].protocol
  source_port_range           = local.db_security_group_rules[count.index].source_port
  destination_port_range      = local.db_security_group_rules[count.index].destination_port
  source_address_prefix       = local.db_security_group_rules[count.index].source_address_prefix
  destination_address_prefix  = local.db_security_group_rules[count.index].destination_address_prefix
  resource_group_name         = azurerm_resource_group.poc_rg.name
  network_security_group_name = azurerm_network_security_group.nsg-spoke[1].name
}

locals {
  db_security_group_rules2 = csvdecode(file("dbrules2.csv"))
}

resource "azurerm_network_security_rule" "db-nsg-rules" {
  count                       = length(local.db_security_group_rules2)
  name                        = "${local.db_security_group_rules2[count.index].name}-${count.index}"
  priority                    = local.db_security_group_rules2[count.index].priority
  direction                   = local.db_security_group_rules2[count.index].direction
  access                      = local.db_security_group_rules2[count.index].access
  protocol                    = local.db_security_group_rules2[count.index].protocol
  source_port_range           = local.db_security_group_rules2[count.index].source_port
  destination_port_range      = local.db_security_group_rules2[count.index].destination_port
  source_address_prefix       = local.db_security_group_rules2[count.index].source_address_prefix
  destination_address_prefix  = local.db_security_group_rules2[count.index].destination_address_prefix
  resource_group_name         = azurerm_resource_group.poc_rg.name
  network_security_group_name = azurerm_network_security_group.nsg-spoke[1].name
}


# Peers Hub VNET to Spoke VNET
resource "azurerm_virtual_network_peering" "Hub-Spoke_Peer" {
  count                        = length(var.spoke_vnet_name)
  name                         = "Hub-To-Spoke"
  resource_group_name          = azurerm_resource_group.poc_rg.name
  virtual_network_name         = azurerm_virtual_network.poc_mgmt_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.poc_spoke_vnet[count.index].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# Peers Spoke VNET to Hub VNET
resource "azurerm_virtual_network_peering" "Spoke-Hub_Peer" {
  count                        = length(var.spoke_vnet_name)
  name                         = "Spoke-To-Hub"
  resource_group_name          = azurerm_resource_group.poc_rg.name
  virtual_network_name         = azurerm_virtual_network.poc_spoke_vnet[count.index].name
  remote_virtual_network_id    = azurerm_virtual_network.poc_mgmt_vnet.id
  allow_virtual_network_access = true
}

