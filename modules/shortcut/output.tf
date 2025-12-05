###############################################
# Outputs for the shortcut module.
###############################################

output "shortcut_id" {
  description = "ID of the shortcut pointing to the CSV file."
  value       = fabric_shortcut.this.id
}

output "shortcut_name" {
  description = "Name of the shortcut."
  value       = fabric_shortcut.this.name
}

output "storage_account_id" {
  description = "Unique identifier of the storage account."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Name of the storage account."
  value       = azurerm_storage_account.this.name
}

output "storage_account_key" {
  description = "Primary access key of the storage account."
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "storage_container_name" {
  description = "Name of the storage container."
  value       = azurerm_storage_container.data.name
}
