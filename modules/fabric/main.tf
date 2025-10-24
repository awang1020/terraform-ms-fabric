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
## Group role assignments per workspace (optional)
locals {
  group_names_for_lookup = toset([
    for a in var.workspace_group_assignments : a.group_display_name
    if try(a.group_object_id, "") == "" && try(a.group_display_name, "") != ""
  ])
}

data "azuread_group" "groups_by_name" {
  for_each     = local.group_names_for_lookup
  display_name = each.key
}

locals {
  all_workspace_names = keys(fabric_workspace.this)

  group_assignment_expanded = flatten([
    for a in var.workspace_group_assignments : [
      for ws_name in (length(try(a.workspaces, [])) > 0 ? a.workspaces : local.all_workspace_names) : {
        key            = "${ws_name}:${coalesce(try(a.group_display_name, null), try(a.group_object_id, null))}:${lower(a.role)}"
        workspace_name = ws_name
        role           = a.role
        group_name     = try(a.group_display_name, null)
        group_object_id = try(a.group_object_id, null)
      }
    ]
  ])

  group_assignment_map = {
    for g in local.group_assignment_expanded :
    g.key => {
      workspace_id = fabric_workspace.this[g.workspace_name].id
      role         = g.role
      principal_id = coalesce(
        g.group_object_id,
        try(data.azuread_group.groups_by_name[g.group_name].object_id, null)
      )
    }
  }
}

resource "fabric_workspace_role_assignment" "groups" {
  for_each    = local.group_assignment_map
  workspace_id = each.value.workspace_id
  role         = each.value.role
  principal = {
    id   = each.value.principal_id
    type = "Group"
  }
}

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
