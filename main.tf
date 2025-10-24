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
  source            = "./modules/fabric"
  capacity_name     = "fc${var.name}"
  workspace_name    = "ws-${var.name}"
  location          = var.location
  capacity_sku      = var.fabric_capacity_sku
  resource_group_id = module.resource_group.id
  administrator_upns = [
    data.azuread_user.current.user_principal_name,
  ]
}
