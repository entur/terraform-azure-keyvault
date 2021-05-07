# Terraform module for Azure Key Vault

Creates a managed Key Vault on Azure.

* Provisions a new Key Vault instance
* Configures a private endpoint connection
* Provisions a Kubernetes secret containing connection information

## Prerequisites
* A preprovisioned landing zone subnet and private DNS zone (in Entur, these have been provided for you)

## Getting started
For example configurations, see the [included examples](examples/).

## Purge protection (important!)
To keep Terraform from purging the Key Vault without soft delete on resource deletion, you'll have to set the `purge_soft_delete_on_destroy` setting in the `azurerm` provider to `false`.

The `purge_soft_delete_on_destroy` setting should be set to `false` when provisioning production instances.

Example:

```
provider "azurerm" {
  [...]
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}
```

## Authentication and authorization
Authentication and authorization is handled outside this module.

## Networking
### Connecting from an application
Application-to-server communication use private endpoint connections, meaning it will communicate privately on a dedicated link from the Kubernetes cluster to the Key Vault instance. Connection information (host) is provided in the [Kubernetes secret](#example-kubernetes-secret). 

### Connecting from a local machine
Public network access is denied by default, meaning the only way to connect to the database is through the private endpoint.

For instructions on how to connect securely from a local machine, please see internal Entur instructions.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| app_name | The name of the associated application | string | N/A | yes |
| environment | The environment name, e.g. 'dev' | string | N/A | yes |
| kubernetes_create_secret | Whether to create Kubernetes secret(s) | bool | true | no |
| kubernetes_namespaces | The namespaces where Kubernetes secret(s) should be created | string | var.app_name | no |
| kubernetes_secret_name | The name of the Kubernetes secret(s) to create | string | Generated | no |
| landing_zone | The landing zone name, e.g. 'dev-001' | string | N/A | yes |
| location | Azure region where the instance should be deployed | string | Norway East | no |
| name | The Key Vault name | string | generated | no |
| purge_protection_enabled | Whether to enable purge protection | bool | true | no |
| soft_delete_retention_days | The number of days that items should be retained for once soft-deleted | number | 90 | no |
| tags | Tags to apply to created resources | map | N/A | yes |

## Outputs

| Name | Description |
|------|-------------|
| key_vault_name | The instance name |
| key_vault_id | The instance object ID |
| key_vault_uri | The Key Vault URI |
| custom_dns_configs | Custom DNS configuration including private IP address |
| host | The fully qualified domain name of the instance |

### Example Kubernetes secret
By default, secret names are prefixed with the application name specified in `var.app_name`, i.e. `<appname>-kvault-credentials`. 

If `var.app_name` = `petshop`, it would produce a secret named `petshop-kvault-credentials`.
```
apiVersion: v1
data:
  KEY_VAULT_HOST: ...
  KEY_VAULT_URI: ...
kind: Secret
[...]
```
