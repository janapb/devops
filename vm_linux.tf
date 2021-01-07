/*
locals{

json_data = jsondecode(file("main.tfvars.json"))

    all_linux_vm = { for k,v in local.deployment.VirtualMachines : k => v
    if v.type == "Linux"
    }
all_linux_vm_disk = { for entry in flatten([
    for key , data in local.all_linux_vm : [
        for dk,disk in lookup(data, "Disk", []): merge({
            vm_name = key
            lun = dk+1
        },disk)
    ]if lookup(data, "Disk",[])!= []
]): "${entry.vm_name}_${entry.name}" => entry }


}
 


resource "azurerm_network_interface" "sn-net-inf" {
 for_each = local.json_data
  name                = format("%s-nic",each.key)
  location            = each.local.value.location
  resource_group_name = each.local.value.resource_group_name
  ip_configuration {
    name      = "IPConfig1"
    subnet_id = each.value.subnet

    private_ip_address            = each.local.value.ip_config
    private_ip_address_allocation = "static"
  }
}


# Create Virtual Machine for Single Node Application and Database
resource "azurerm_linux_virtual_machine" "sn_vm" {
  count               = length(var.sn_vm)
  name                = var.sn_vm[count.index].name
  resource_group_name = azurerm_resource_group.poc_rg.name
  location            = azurerm_resource_group.poc_rg.location
  size                = var.app_os.size
  computer_name       = var.sn_vm[count.index].name
  admin_username      = "swo_admin"
  network_interface_ids = [
    azurerm_network_interface.sn-net-inf[count.index].id,
  ]

  admin_ssh_key {
    username   = "swo_admin"
    public_key = file("id_rsa.pub")
  }

  os_disk {
    name                 = "${var.sn_vm[count.index].name}-os_disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.app_os.publisher
    offer     = var.app_os.offer
    sku       = var.app_os.sku
    version   = var.app_os.version
  }
}


resource "azurerm_managed_disk" "sn_data_disks" {
  for_each = var.sn_data_disks

  name                 = "${var.sn_name}-data_disk${each.value.lun + 1}"
  location             = azurerm_resource_group.poc_rg.location
  resource_group_name  = azurerm_resource_group.poc_rg.name
  storage_account_type = each.value.type
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "sn_data_disks" {
  for_each = var.sn_data_disks

  managed_disk_id    = azurerm_managed_disk.sn_data_disks[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.sn_vm[0].id
  lun                = each.value.lun
  caching            = "ReadWrite"
}

*/