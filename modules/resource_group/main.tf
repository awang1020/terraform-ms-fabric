###############################################
# Resource group module
# Responsible for provisioning the Azure resource group
# that hosts Microsoft Fabric assets.
###############################################

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}


# Input variables are defined in variables.tf within this module.

# Create the Azure resource group that will contain the Fabric resources.
resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}

# Expose selected properties of the resource group to parent modules.
output "id" {
  description = "Unique identifier of the resource group."
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "Name of the created resource group."
  value       = azurerm_resource_group.this.name
}
