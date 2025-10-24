############################################################
# Root module for Microsoft Fabric infrastructure deployment
# This configuration wires together supporting modules and
# data sources to provision a resource group, Fabric capacity,
# and workspace following recommended practices.
############################################################

# -----------------------------------------------------------------------------
# Discover details about the currently authenticated Azure client.
# This is used to infer defaults such as the administrator account.
# -----------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

# -----------------------------------------------------------------------------
# Resolve the Azure AD user principal for the signed-in identity so the
# workspace administration can be automatically assigned.
# -----------------------------------------------------------------------------
data "azuread_user" "current" {
  object_id = data.azurerm_client_config.current.object_id
}

# Centralize administrator UPNs for reuse across modules/resources.
locals {
  # Normalize client/env to lowercase hyphenated slugs
  client_slug = lower(var.client)
  env_slug    = lower(var.environment)

  # Build an alphanumeric-only capacity name that starts with a letter
  # and stays within 63 characters as required by the provider.
  capacity_base     = "${replace(local.client_slug, "-", "")}fabriccapacity${local.env_slug}"
  capacity_name_pre = substr(lower(local.capacity_base), 0, 63)
  capacity_name     = can(regex("^[a-z].*", local.capacity_name_pre)) ? local.capacity_name_pre : "f${substr(local.capacity_name_pre, 0, 62)}"

  # Standard names across resources
  names = {
    resource_group = "${local.client_slug}-fabric-rg-${local.env_slug}"
    capacity       = local.capacity_name
    workspace      = "${local.client_slug}-fabric-workspace-${local.env_slug}"
  }

  administrator_upns = [
    data.azuread_user.current.user_principal_name,
  ]
}

# -----------------------------------------------------------------------------
# Provision the resource group hosting all Microsoft Fabric resources.
# -----------------------------------------------------------------------------
module "resource_group" {
  source   = "./modules/resource_group"
  name     = local.names.resource_group
  location = var.location
}

# -----------------------------------------------------------------------------
# Deploy the Microsoft Fabric capacity and workspace resources.
# -----------------------------------------------------------------------------
module "fabric" {
  source        = "./modules/fabric"
  capacity_name = local.names.capacity
  # Create three workspaces on the same capacity
  workspace_names     = [for n in ["DEV", "TEST", "PROD"] : "${local.client_slug}-${n}"]
  location            = var.location
  capacity_sku        = var.fabric_capacity_sku
  resource_group_name = module.resource_group.name
  administrator_upns  = local.administrator_upns
}

# Resolve Azure AD objects for each administrator UPN.
data "azuread_user" "admins" {
  for_each            = toset(local.administrator_upns)
  user_principal_name = each.value
}

# Assign Owner role on the Fabric Capacity to administrators.
resource "azurerm_role_assignment" "capacity_admins" {
  for_each             = data.azuread_user.admins
  scope                = module.fabric.capacity.id
  role_definition_name = "Owner"
  principal_id         = each.value.object_id
}

# Assign Owner on the Resource Group to administrators (optional but useful).
resource "azurerm_role_assignment" "rg_admins" {
  for_each             = data.azuread_user.admins
  scope                = module.resource_group.id
  role_definition_name = "Owner"
  principal_id         = each.value.object_id
}
