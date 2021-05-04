variable "location" {
  type    = string
  default = "Norway East"
}

variable "tags" {
  type    = map
  default = {}
}

variable "resource_group_name" {
  type    = string
  default = "rg-example-app"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "landing_zone" {
  type    = string
  default = "dev-001"
}

variable "app_name" {
  type    = string
  default = "example-app"
}

variable "kv_disable_soft_delete" {
  description = "Whether Key Vault resources should be permanently deleted when destroyed"
  type        = bool
  default     = false
}