locals {
  lz = jsondecode(file("lz_input.json"))
}

resource "azurerm_storage_account" "storage" {
  count  = length(local.lz.Terraformstate)
  name                     = lookup(element(local.lz.Terraformstate,count.index),"Storagename")
  resource_group_name      = lookup(element(local.lz.Terraformstate,count.index),"Resourcegroup_Name")
  location                 = lookup(element(local.lz.Terraformstate,count.index),"Location")
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = merge(local.lz.Tags[count.index])
}
resource "azurerm_storage_container" "tfcontainer" {
  count  = length(local.lz.Terraformstate)
  name                  = lookup(element(local.lz.Terraformstate,count.index),"Containername")
  #resource_group_name   = lookup(element(local.lz.Terraformstate,count.index),"Resourcegroup_Name")
  storage_account_name  = lookup(element(local.lz.Terraformstate,count.index),"Storagename")
  container_access_type = "private"
}
