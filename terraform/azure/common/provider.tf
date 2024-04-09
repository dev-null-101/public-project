provider "azurerm" {
  features {}
  subscription_id = var.subscriptionid
  client_id       = var.appid
  client_secret   = var.secret
  tenant_id       = var.tenantid
}
