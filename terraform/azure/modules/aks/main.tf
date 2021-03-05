locals {
  cluster_name = "${var.prefix}-${var.env}-aks-${var.name}-${var.location}"
  node_rg_name = "${var.prefix}-${var.env}-rg-aks-${var.name}-node-${var.location}"
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "this" {
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  name                = local.cluster_name
  dns_prefix          = local.cluster_name
  kubernetes_version  = var.kubernetes_version
  node_resource_group = local.node_rg_name
  tags                = var.common_tags

  sku_tier = "Paid" # this will influence SLA uptime
  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = var.ssh_key
    }
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
  }

  default_node_pool {
    name               = "system"
    availability_zones = var.availability_zones
    vm_size            = var.default_system_node_pool.vm_size
    max_pods           = var.default_system_node_pool.max_pods

    vnet_subnet_id = var.subnet_id

    enable_auto_scaling = true
    max_count           = var.default_system_node_pool.max_node_count
    min_count           = var.default_system_node_pool.min_node_count
    os_disk_type        = var.default_system_node_pool.os_disk_type
    os_disk_size_gb     = var.default_system_node_pool.os_disk_size_gb
    node_labels         = var.default_system_node_pool.node_labels
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.node_pools

  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  name                  = each.key
  vm_size               = each.value.vm_size
  max_pods              = each.value.max_pods

  vnet_subnet_id = var.subnet_id

  availability_zones  = var.availability_zones
  enable_auto_scaling = true
  max_count           = each.value.max_node_count
  min_count           = each.value.min_node_count
  mode                = each.value.node_mode
  os_type             = each.value.os_type
  os_disk_type        = each.value.os_disk_type
  os_disk_size_gb     = each.value.os_disk_size_gb
  node_labels         = each.value.node_labels
  node_taints         = each.value.node_taints
}

resource "azurerm_role_assignment" "network" {
  scope                = data.azurerm_resource_group.this.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

module "autoscaler" {
  source                        = "../autoscaler"
  aks_cluster_name              = azurerm_kubernetes_cluster.this.name
  resource_group_name           = data.azurerm_resource_group.this.name
  expander                      = var.auto_scaler_profile.expander
  skip_nodes_with_local_storage = var.auto_scaler_profile.skip_nodes_with_local_storage
  balance_similar_node_groups   = var.auto_scaler_profile.balance_similar_node_groups

  depends_on = [azurerm_kubernetes_cluster.this]
}