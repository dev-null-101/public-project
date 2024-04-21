provider "azurerm" {
  features {}
}

#	rg-<app or service name>-<subscription purpose>-<###>
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

# vnet-<subscription purpose>-<region>-<###>
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

# snet-<subscription purpose>-<region>-<###>
resource "azurerm_subnet" "example" {
  count                = 2
  name                 = "subnet-${count.index}"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.example.name
  address_prefixes     = ["10.0.${count.index}.0/24"]
}

# nsg-<policy name or app name>-<###>
resource "azurerm_network_security_group" "example" {
  count               = 2
  name                = "example-nsg-${count.index}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet_network_security_group_association" "example" {
  count                 = 2
  subnet_id             = azurerm_subnet.example[count.index].id
  network_security_group_id = azurerm_network_security_group.example[count.index].id
}
