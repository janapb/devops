
# Creates the public IP addresses for Windows jumpboxes
resource "azurerm_public_ip" "jump-win-pub-ip" {
  count               = length(var.jmp-vm-win)
  name                = var.jmp-vm-win[count.index]
  location            = azurerm_resource_group.poc_rg.location
  resource_group_name = azurerm_resource_group.poc_rg.name
  allocation_method   = "Static"
}

# Creates the NIC and IP address for Windows jumpboxes
resource "azurerm_network_interface" "jmp_net_inf" {
  count               = length(var.jmp-vm-win)
  name                = "jmp-vm-win${count.index}-NIC"
  location            = azurerm_resource_group.poc_rg.location
  resource_group_name = azurerm_resource_group.poc_rg.name

  ip_configuration {
    name                          = "NicConfiguration"
    subnet_id                     = azurerm_subnet.hub_subnet[1].id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.jump-win-pub-ip[count.index].id
  }
}


# Manages Windows Virtual Machine for Windows jumpboxes
resource "azurerm_windows_virtual_machine" "jump-win-vm" {
  count               = length(var.jmp-vm-win)
  name                = upper(var.jmp-vm-win[count.index])
  resource_group_name = azurerm_resource_group.poc_rg.name
  location            = azurerm_resource_group.poc_rg.location
  size                = var.app_os_jump.size
  admin_username      = "swo_admin"
  admin_password      = "Password@1234!"
  computer_name       = upper(var.jmp-vm-win[count.index])
  network_interface_ids = [
    azurerm_network_interface.jmp_net_inf[count.index].id
  ]

  os_disk {
    name                 = "${var.jmp-vm-win[count.index]}-os_disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = var.app_os_jump.publisher
    offer     = var.app_os_jump.offer
    sku       = var.app_os_jump.sku
    version   = var.app_os_jump.version
  }
    tags = {
    Name = "Jumpbox"
    Env  = "Pilot"
  }
}


#output "Jumpbox_ip"{
#    value=azurerm_public_ip.jump-win-pub-ip[*].id
#}
