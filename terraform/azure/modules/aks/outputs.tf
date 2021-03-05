output "id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "name" {
  value = azurerm_kubernetes_cluster.this.id != "" ? azurerm_kubernetes_cluster.this.name : azurerm_kubernetes_cluster.this.name
}

output "resource_group" {
  value = azurerm_kubernetes_cluster.this.resource_group_name
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.this.id != "" ? azurerm_kubernetes_cluster.this.node_resource_group : azurerm_kubernetes_cluster.this.node_resource_group
}

output "kubelet_identity" {
  value = {
    client_id                 = azurerm_kubernetes_cluster.this.kubelet_identity.0.client_id
    object_id                 = azurerm_kubernetes_cluster.this.kubelet_identity.0.object_id
    user_assigned_identity_id = azurerm_kubernetes_cluster.this.kubelet_identity.0.user_assigned_identity_id
  }
}