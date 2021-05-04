locals {
  # If kubernetes_create_secret == false, set var.kubernetes_namespaces as empty list.
  # If kubernetes_create_secret == true, use var.kubernetes_namespaces if set.
  # If kubernetes_create_secret == true but var.kubernetes_namespaces is not set (default), set it to a single entry list containing var.app_name.
  kubernetes_namespaces = var.kubernetes_create_secret == false ? [] : length(var.kubernetes_namespaces) > 0 ? var.kubernetes_namespaces : [var.app_name]

  kubernetes_secret_name = var.kubernetes_secret_name != null ? var.kubernetes_secret_name : "${var.app_name}-kvault-credentials"
  key_vault_name         = var.name != null ? var.name : "kv-${local.shortened_app_name}-${var.environment}"
  shortened_app_name     = replace(substr(var.app_name, 0, 14), "-", "")
}

data "azurerm_client_config" "current" {}

# Create Key Vault instance
resource "azurerm_key_vault" "main" {
  name                       = local.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled
  enable_rbac_authorization  = true

  sku_name = "standard"

  network_acls {
    bypass         = "None"
    default_action = "Deny"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Network - private endpoint connection
data "azurerm_subnet" "aks" {
  name                 = "${var.aks_connections_subnet_name_prefix}-${var.landing_zone}"
  virtual_network_name = "${var.vnet_name_prefix}-${var.landing_zone}"
  resource_group_name  = "${var.network_resource_group_prefix}-${var.landing_zone}"
}

# Establish a private endpoint connection
resource "azurerm_private_endpoint" "aks" {
  name                = "pe-aks-${azurerm_key_vault.main.name}"
  location            = var.location
  resource_group_name = data.azurerm_subnet.aks.resource_group_name
  subnet_id           = data.azurerm_subnet.aks.id

  private_service_connection {
    name                           = "pec-aks-${azurerm_key_vault.main.name}"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["Vault"]
    is_manual_connection           = false
  }
}

# Create a private DNS record for use with private endpoint connection
resource "azurerm_private_dns_a_record" "privatelink" {
  name                = azurerm_key_vault.main.name
  resource_group_name = data.azurerm_subnet.aks.resource_group_name
  zone_name           = "privatelink.vaultcore.azure.net"
  ttl                 = 60
  records             = azurerm_private_endpoint.aks.custom_dns_configs[0].ip_addresses
}

# Provision connection information in Kubernetes cluster
resource "kubernetes_secret" "privatelink" {
  for_each = { for ns in local.kubernetes_namespaces : ns => ns }

  metadata {
    name      = local.kubernetes_secret_name
    namespace = each.value
    labels    = var.tags
  }

  data = {
    KEY_VAULT_HOST = azurerm_private_dns_a_record.privatelink.fqdn
  }
}