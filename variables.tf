# Azure global variables
variable "location" {
  description = "Default Azure resource location"
  type        = string
  default     = "Norway East"
}

variable "resource_group_name" {
  description = "The name of the resource group in which the Azure Key Vault instance will be created."
  type        = string
}

variable "app_name" {
  description = "The name of the associated application"
  type        = string
}

variable "environment" {
  description = "The environment name, e.g. 'dev'"
  type        = string
}

variable "landing_zone" {
  description = "The landing zone name, e.g. 'dev-001'"
  type        = string
}

variable "tags" {
  description = "Tags to attach to resources"
  type        = map
}

variable "name" {
  description = "Key Vault name (override)"
  type        = string
  default     = null
}

# Key Vault settings
variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted"
  type        = number
  default     = 90
}

variable "purge_protection_enabled" {
  description = "Whether to enable purge protection"
  type        = bool
  default     = true
}

# Network variables
variable "vnet_name_prefix" {
  description = "Vnet name prefix where the nodes and pods will be deployed"
  type        = string
  default     = "vnet"
}

variable "aks_connections_subnet_name_prefix" {
  description = "Subnet name prefix of subnets where Azure private endpoint connections will be created"
  type        = string
  default     = "snet-aks-connections"
}

variable "network_resource_group_prefix" {
  description = "Name prefix of the network resource group"
  type        = string
  default     = "rg-networks"
}

# Kubernetes variables
variable "kubernetes_create_secret" {
  description = "Whether to create a Kubernetes secret"
  type        = bool
  default     = true
}

variable "kubernetes_namespaces" {
  description = "The namespaces where a Kubernetes secret should be created"
  type        = list(string)
  default     = []
}

variable "kubernetes_secret_name" {
  description = "The name of the Kubernetes secret to create"
  type        = string
  default     = null
}
