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
  administrator_upns = [
    data.azuread_user.current.user_principal_name,
  ]
}

# -----------------------------------------------------------------------------
# Provision the resource group hosting all Microsoft Fabric resources.
# -----------------------------------------------------------------------------
module "resource_group" {
  source   = "./modules/resource_group"
  name     = "rg-${var.name}"
  location = var.location
}

# -----------------------------------------------------------------------------
# Deploy the Microsoft Fabric capacity and workspace resources.
# -----------------------------------------------------------------------------
module "fabric" {
  source              = "./modules/fabric"
  capacity_name       = "fc${var.name}"
  workspace_name      = "ws-${var.name}"
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
