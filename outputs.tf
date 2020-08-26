// Azure
output "azure-instance-ip" {
  value = azurerm_linux_virtual_machine.hashidemos.public_ip_address
}