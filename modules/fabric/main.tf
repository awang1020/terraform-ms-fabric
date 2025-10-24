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

# Lookup the Fabric capacity GUID for use by Fabric APIs.
data "fabric_capacity" "this" {
  display_name = var.capacity_name
}

# Create a Fabric workspace bound to the capacity.
resource "fabric_workspace" "this" {
  capacity_id  = data.fabric_capacity.this.id
  display_name = var.workspace_name
}

# Resolve AAD object IDs for administrator UPNs.
data "azuread_user" "admins" {
  for_each            = toset(var.administrator_upns)
  user_principal_name = each.value
}

# Read existing role assignments to avoid duplicates.
data "fabric_workspace_role_assignments" "existing" {
  workspace_id = fabric_workspace.this.id
}

locals {
  existing_admin_object_ids = toset([
    for v in data.fabric_workspace_role_assignments.existing.values : v.principal.id
  ])
}

# Assign Admin role within the Fabric workspace to administrators.
resource "fabric_workspace_role_assignment" "admins" {
  for_each     = { for k, v in data.azuread_user.admins : k => v if !(contains(local.existing_admin_object_ids, v.object_id)) }
  workspace_id = fabric_workspace.this.id
  role         = "Admin"
  principal = {
    id   = each.value.object_id
    type = "User"
  }
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
