# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  #version         = "=2.20.0"
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

/*# Backend for softwareonedev
terraform {
  backend "azurerm" {
    tenant_id            = "d892a081-1f19-49f6-94c3-2ef56720126e"
    subscription_id      = "249a3bf8-18cc-4f88-ab0e-77e87f943d8c"
    resource_group_name  = "terraform-poc-rg"
    storage_account_name = "tfatushstorageacc2"
    container_name       = "tstate-dev-cont"
    #key                  = "tfatushstorageacc2"
    key                  = "terraform.tfstate"
  }
}
*/
# Backend for Comparex
terraform {
  backend "azurerm" {
    tenant_id            = "8ac8c880-b237-4c0a-880d-fd41b2636c6a"
    subscription_id      = "2969c0b7-f92f-49b7-b7e6-d3135583ad6e"
    resource_group_name  = "AZ_LANDING_TEST"
    storage_account_name = "devcomptfstorage"
    container_name       = "devcomptfcontainer"
    key                  = "dev.tf.state"
  }
}


/*

#*************************

terraform {
  backend "azurerm" {
    tenant_id            = "xxxxxxxx-84e2-4390-b0b9-c79fdf7323ea"
    subscription_id      = "xxxxxxxx-b1ee-41e4-8bd5-e4a04300b5c1"
    resource_group_name  = "rg-tfstates-prod"
    storage_account_name = "stprod"
    container_name       = "prod"
key      = "core-routing/terraform.tfstate"
    snapshot = true
  }
}

subscription_id = "249a3bf8-18cc-4f88-ab0e-77e87f943d8c"
client_id       = "39c731e9-6191-4639-95b3-1b2fdfd196a0"
client_secret   = "j0.VTeCP1TL-rN0UNL8j3JgS~_8oBRa.6C"
tenant_id       = "d892a081-1f19-49f6-94c3-2ef56720126e"


*/

