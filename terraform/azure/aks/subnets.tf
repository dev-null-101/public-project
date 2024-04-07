resource "azurerm_subnet" "aks_snet_01" {
    name = "snet-aks-01"
    address_prefixes = ["10.0.0.0/19"]
    resource_group_name = azurerm_resource_group.aks_rg.name
    virtual_network_name = azurerm_virtual_network.aks_vnet.name
}

resource "azurerm_subnet" "aks_snet_02" {
    name = "snet-aks-02"
    address_prefixes = ["10.0.32.0/19"]
    resource_group_name = azurerm_resource_group.aks_rg.name
    virtual_network_name = azurerm_virtual_network.aks_vnet.name
}

# For existing subnet
# data "azurerm_subnet" "aks_snet_01" {
#     name = "snet-aks-01"
#     virtual_network_name = azurerm_virtual_network.aks_vnet.name
#     resource_group_name = azurerm_resource_group.aks_rg.name
# }

# output "subnet_id" {
#     value = data.azurerm_subnet.aks_snet_01.id 
# }
