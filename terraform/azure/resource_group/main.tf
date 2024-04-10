# provider "azurerm" {
#   features {}
#   subscription_id = var.subscriptionid
#   client_id       = var.appid
#   client_secret   = var.secret
#   tenant_id       = var.tenantid
# }
module "azurerm" {
  source = "./modules/azure_provider"
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "Southeast Asia"
}
