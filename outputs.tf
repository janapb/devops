output "Jumpbox_ip"{
    value=azurerm_public_ip.jump-win-pub-ip[*].id
}