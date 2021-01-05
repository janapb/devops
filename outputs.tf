output "resourcegroup" {
  value = azurerm_resource_group.poc_rg.name
}

output "jump_id" {
value = azurerm_subnet.hub_subnet[1].id
}