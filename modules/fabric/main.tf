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
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}




# Create a Microsoft Fabric capacity using the AzAPI provider.
resource "azurerm_fabric_capacity" "this" {
  name                = var.capacity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    name = var.capacity_sku
    tier = "Fabric"
  }

  administration_members = var.administrator_upns

  tags = var.tags
}

# Lookup the Fabric capacity GUID for use by Fabric APIs (phase 2).
data "fabric_capacity" "this" {
  display_name = var.capacity_name
}

# Create a Fabric workspace bound to the capacity.
locals {
  effective_workspace_names = length(var.workspace_names) > 0 ? var.workspace_names : (var.workspace_name != null ? [var.workspace_name] : [])
}

resource "fabric_workspace" "this" {
  for_each     = { for n in local.effective_workspace_names : n => n if n != null }
  capacity_id  = data.fabric_capacity.this.id
  display_name = each.value
}

# Resolve AAD object IDs for administrator UPNs.
data "azuread_user" "admins" {
  for_each            = toset(var.administrator_upns)
  user_principal_name = each.value
}

# Build static keys for admin assignments across all workspaces and admins.
locals {}

# Assign Admin role within the Fabric workspace to administrators.
## Note: Workspace Admin role assignment intentionally omitted to avoid
## duplicate-assignment errors since creators are already Admin by default.

# Expose useful outputs to calling modules.
output "capacity" {
  description = "Fabric capacity details including identifiers."
  value       = azurerm_fabric_capacity.this
}

output "workspace" {
  description = "Fabric workspace resource output (single). Null when multiple workspaces are created."
  value       = length(local.effective_workspace_names) == 1 && length(local.effective_workspace_names) > 0 ? fabric_workspace.this[local.effective_workspace_names[0]] : null
}

output "workspaces" {
  description = "Map of Fabric workspaces created in this module."
  value       = fabric_workspace.this
}
