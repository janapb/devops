# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version         = "=2.20.0"
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}
variable "subscription_id" {
  description = "Enter Subscription ID for provisioning resources in Azure"
}
variable "client_id" {
  description = "Enter Client ID for provisioning resources in Azure"
}

variable "client_secret" {
  description = "Enter Client secret for provisioning resources in Azure"
}
variable "tenant_id" {
  description = "Enter Tenant ID / Directory ID  for provisioning resources in Azure"
}
variable "location" {
  description = "Enter Location  for provisioning resources in Azure"
}
variable "comman_tags" {
  description = " Enter the common tags used for provisioning"
}
variable "rg_name" {
  default = "Testing_ResourceGroup"
}

variable "mgmt_vnet_name" {
  description = "Enter the Management Hub Virtual Network"
}

variable "mgmt_vnet_cidr" {
  description = "Enter the CIDR space address for Management Virtual Hub Network"
}