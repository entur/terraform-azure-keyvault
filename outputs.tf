output key_vault_name {
  value = azurerm_key_vault.main.name
}

output key_vault_id {
  value = azurerm_key_vault.main.id
}

output custom_dns_configs {
  value = azurerm_private_endpoint.aks.custom_dns_configs
}

output host {
  value = azurerm_private_dns_a_record.privatelink.fqdn
}