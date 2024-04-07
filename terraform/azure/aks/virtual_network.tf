resource "azurerm_virtual_network" "aks_vnet" {
    name                = "vnet-aks"
    address_space       = ["10.0.0.0/16"]
    location            = local.region
    resource_group_name = azurerm_resource_group.aks_rg.name
  
    tags = {
        env = local.env
    }
}

