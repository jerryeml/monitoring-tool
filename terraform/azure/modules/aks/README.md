# Azure Kubernetes Service
Azure managed Kubernetes Service with one default system node pool, and some specific node pools.

Provisioned AKS will be grant "Network Contributor" permission on resource group scope to control load balance and etc.

## Variables
__Common variables__
- common_tags _(required)_
- location _(required)_
- prefix _(required)_
- env _(required)_

__Other variables__
- resource_group_name _(required)_  
  Resource group to deploy aks
- subnet_id _(required)_  
  The id of the subnet where node pool should exist. At this time the vnet_subnet_id must be the same for all node pools in the cluster
- kubernetes_version _(required)_  
  Version of kubernetes specified when creating the AKS managed cluster
- ssh_key _(required)_  
  The public ssh key used to access the cluster
- network_plugin _(required)_  
  Network plugin to use for networking, azure or kubenet
- availability_zones _(option)_  
  List of availability zones where the nodes should be created in  
  _default value_: ["1", "2", "3"]
- service_cidr _(required)_  
  k8s service cidr, aws default is 172.20.0.0/16
- dns_service_ip _(required)_  
  IP address within the kubernetes service address range that will be used by cluster service discovery
- docker_bridge_cidr _(required)_  
  Used as the docker bridge IP address on nodes, ex: 100.65.0.10/16 Azure will use 100.65.0.10 as the first IP for docker bridge
- default_system_node_pool _(required)_  
  Default system node pool configuration  
  Default node pool should be __SYSTEM__ role and cannot set customized taints  
  _format_ example:
  ```
  {
    vm_size         = "Standard_F4s_v2"
    max_pods        = 44
    min_node_count  = 3
    max_node_count  = 15
    os_disk_type    = "Managed"
    os_disk_size_gb = 128
    node_labels     = {}
  }
  ```
  
- node_pools _(required)_  
  Node pools configuration, map key as pool name
  _format_ example:
  ```
  {
    default : {
      vm_size         = "Standard_F4s_v2"
      max_pods        = 44
      min_node_count  = 3
      max_node_count  = 15
      os_type         = "Linux"
      os_disk_type    = "Managed"
      os_disk_size_gb = 128
      node_labels     = {}
      node_taints     = []
      node_mode       = "User"
    },
    monitoring : {
      vm_size         = "Standard_E4ds_v4"
      max_pods        = 44
      min_node_count  = 2 # min == max: no auto scale
      max_node_count  = 2
      os_type         = "Linux"
      os_disk_type    = "Managed"
      os_disk_size_gb = 128
      node_labels     = { dedicated : "prometheus" }
      node_taints     = ["dedicated=prometheus:NoSchedule"]
      node_mode       = "User"
    }
  }
  ```

## Outputs
- id  
  ID of AKS
- name  
  Name of AKS
- resource_group  
  The Resource Group of AKS master exists
- node_resource_group  
  The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster
- kubelet_identity  
  AKS agent pool identity
  ```buildoutcfg  
  {
    "client_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "object_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "user_assigned_identity_id": "/subscriptions/59f2ffd5-9a7d-4980-96d2-a9f7b5e21c74/resourceGroups/pal-test-rg-aks-default-node-eastus2/providers/Microsoft.ManagedIdentity/userAssignedIdentities/pal-test-aks-default-eastus2-agentpool"
  }
  ```

## Resources
- azurerm_kubernetes_cluster
- azurerm_kubernetes_cluster_node_pool
- azurerm_role_assignment
