###############################################
# Fabric module
# Provisions a Fabric capacity and workspace in a
# specified resource group and assigns administrators.
###############################################

terraform {
  required_providers {
    fabric = {
      source = "microsoft/fabric"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}




# Create a Microsoft Fabric capacity using the AzAPI provider.
resource "azurerm_fabric_capacity" "this" {
  name                = var.capacity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = {
    name = var.capacity_sku
    tier = "Fabric"
  }

  administration {
    members = var.administrator_upns
  }

  tags = var.tags
}

# Create a Fabric workspace bound to the capacity.
resource "fabric_workspace" "this" {
  capacity_id  = azurerm_fabric_capacity.this.id
  display_name = var.workspace_name
}

# Expose useful outputs to calling modules.
output "capacity" {
  description = "Fabric capacity details including identifiers."
  value       = azurerm_fabric_capacity.this
}

output "workspace" {
  description = "Fabric workspace resource output."
  value       = fabric_workspace.this
}
