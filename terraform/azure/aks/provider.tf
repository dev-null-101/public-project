provider "azurerm" {
    features {}
    subscription_id = var.subscriptionid
    client_id       = var.appid
    client_secret   = var.secret
    tenant_id       = var.tenantid
}

terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "3.75.0"
    }
    helm = {
        source = "hashicorp/helm"
        version = ">= 2.1.0"
    }
  }
}
