resource tls_private_key "hashidemos" {
  algorithm = "RSA"
}

provider "azurerm" {
  features {}
  version = "~> 2.0"
}

resource "azurerm_resource_group" "hashidemos" {
  name     = var.prefix
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "hashidemos" {
  name                = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.hashidemos.name
  tags                = local.common_tags
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = var.prefix
  resource_group_name  = azurerm_resource_group.hashidemos.name
  virtual_network_name = azurerm_virtual_network.hashidemos.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "hashidemos" {
  name                = var.prefix
  location            = azurerm_resource_group.hashidemos.location
  resource_group_name = azurerm_resource_group.hashidemos.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.hashidemos.id
  network_security_group_id = azurerm_network_security_group.hashidemos.id
}

resource "azurerm_public_ip" "publicip" {
  name                = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.hashidemos.name
  tags                = local.common_tags
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "hashidemos" {
  name                = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.hashidemos.name
  tags                = local.common_tags

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-https"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "internal-hashidemos" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.hashidemos.id
}

resource "azurerm_linux_virtual_machine" "hashidemos" {
  name                = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.hashidemos.name
  admin_username      = var.admin_username
  tags                = local.common_tags
  size                = "Standard_B1s"

  network_interface_ids = [
    azurerm_network_interface.hashidemos.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.hashidemos.public_key_openssh
  }

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
