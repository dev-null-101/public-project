resource "azurerm_resource_group" "aks_rg" {
    name = local.resource_group_name
    location = local.region
}