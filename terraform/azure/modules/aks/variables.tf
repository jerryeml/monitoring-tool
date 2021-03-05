variable "prefix" {
  description = "current town name"
  type        = string
}

variable "env" {
  description = "current environment"
  type        = string
}

variable "name" {
  description = "name"
  type        = string
}

variable "location" {
  description = "location name"
  type        = string
}

variable "resource_group_name" {
  description = "resource group name"
  type        = string
}

variable "common_tags" {
  description = "common tags"
  type        = map(string)
}

variable "subnet_id" {
  description = "the id of the subnet where node pool should exist. At this time the vnet_subnet_id must be the same for all node pools in the cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "version of kubernetes specified when creating the AKS managed cluster"
  type        = string
}

variable "ssh_key" {
  description = "the public ssh key used to access the cluster"
  type        = string
}

variable "network_plugin" {
  description = "network plugin to use for networking, azure or kubenet"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Sets up network policy to be used with Azure CNI. calico or azure."
  type        = string
  default     = "azure"
}

variable "availability_zones" {
  description = "list of availability zones where the nodes should be created in"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "service_cidr" {
  description = "k8s service cidr, aws default is 172.20.0.0/16"
  type        = string
}

variable "dns_service_ip" {
  description = "IP address within the kubernetes service address range that will be used by cluster service discovery"
  type        = string
}

variable "docker_bridge_cidr" {
  description = "used as the docker bridge IP address on nodes, ex: 100.65.0.10/16 Azure will use 100.65.0.10 as the first IP for docker bridge"
  type        = string
}

variable "default_system_node_pool" {
  description = "default system node pool configuration"
  type = object({
    vm_size         = string
    max_pods        = number
    max_node_count  = number
    min_node_count  = number
    os_disk_type    = string
    os_disk_size_gb = number
    node_labels     = map(string)
  })
}

variable "node_pools" {
  description = "node pools configuration, map key as pool name"
  type = map(object({
    vm_size         = string
    max_pods        = number
    max_node_count  = number
    min_node_count  = number
    os_type         = string
    os_disk_type    = string
    os_disk_size_gb = number
    node_labels     = map(string)
    node_taints     = list(string)
    node_mode       = string
  }))
}

variable "auto_scaler_profile" {
  description = "cluster autoscaler configuration"
  type = object({
    balance_similar_node_groups   = string
    expander                      = string
    skip_nodes_with_local_storage = string
  })
  default = {
    balance_similar_node_groups   = "false"
    expander                      = "most-pods"
    skip_nodes_with_local_storage = "true"
  }
}