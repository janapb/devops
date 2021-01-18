data "azurerm_resources" "listofresource" {
resource_group_name      ="AZ_LANDING_TEST"
}

output "resources"{
value = data.azurerm_resources.listofresource
}

/*
output tfstates {
  value     = local.terraform.tfstate
  sensitive = true
}
*/