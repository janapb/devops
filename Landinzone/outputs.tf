output "resource_group"{
    value = azurerm_resource_group.lz_rg.*.name
}


output "virtual_network"{
    value = azurerm_virtual_network.lz_vnet.*.id
}

output "subnet"{
    value = azurerm_subnet.lz_subnet.*.id
}

output "tags"{
  value=local.lz.Tags
}
