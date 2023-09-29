provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = var.kv_disable_soft_delete
    }
  }
}

provider "kubernetes" {}

module "keyvault" {
  source = "github.com/entur/terraform-azure-keyvault?ref=v0.0.3"
  # source = "../"

  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  app_name                   = var.app_name
  environment                = var.environment
  landing_zone               = var.landing_zone
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = var.soft_delete_retention_days
}
