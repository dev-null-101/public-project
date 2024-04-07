resource "azurerm_user_assigned_identity" "aks_msi" {
  name                = "id-aks"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_role_assignment" "aks_role" {
    scope                = azurerm_resource_group.aks_rg.id
    role_definition_name = "Network Contributor"
    principal_id         = azurerm_user_assigned_identity.msi_aks.principal_id
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
    name = "${local.env}-${local.aks_name}"
    location = azurerm_resource_group.aks_rg.location
    resource_group_name = azurerm_resource_group.aks_rg.name
    dns_prefix = "devaks01"

    kubernetes_version = local.aks_version
    automatic_channel_upgrade = "stable"
    private_cluster_enabled = false
    node_resource_group = "${local.resource_group_name}-${local.env}-${local.aks_name}"

    # In Preview
    # api_server_access_profile {
    #   vnet_integration_enabled = true
    #   subnet_id = azurerm_subnet.aks_snet_01.id
    # }

    # "Standard" - for non-dev
    sku_tier = "Free"

    oidc_issuer_enabled = true
    workload_identity_enabled = true

    network_profile {
      network_plugin = "azure"
      dns_service_ip = "10.0.64.10"
      service_cidr = "10.0.64.0/19"
    }

    default_node_pool {
      name = "general"
      vm_size = "Standard_D2_v2"
      vnet_subnet_id =  azurerm_subnet.aks_snet_01.id
      orchestrator_version = local.aks_version
      type = "VirtualMachineScaleSets"
      enable_auto_scaling =  true
      node_count = 1
      min_count = 1
      max_count = 10
    }

    node_labels = {
        role = "general"
    }

    identity {
      type = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.aks_msi.id]
    }

    tags = {
      env = local.env
    }
}