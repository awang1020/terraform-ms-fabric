###############################################
# Fabric module
# Provisions a Fabric capacity and workspace in a
# specified resource group and assigns administrators.
###############################################

# Create a Microsoft Fabric capacity using the AzAPI provider.
resource "azapi_resource" "capacity" {
  type                      = "Microsoft.Fabric/capacities@2023-11-01"
  name                      = var.capacity_name
  parent_id                 = var.resource_group_id
  location                  = var.location
  schema_validation_enabled = false

  body = {
    sku = {
      name = var.capacity_sku
      tier = "Fabric"
    }
    properties = {
      administration = {
        members = var.administrator_upns
      }
    }
  }
}

# Retrieve the Fabric capacity information once provisioned.
data "fabric_capacity" "this" {
  display_name = azapi_resource.capacity.name
}

# Create a Fabric workspace bound to the capacity.
resource "fabric_workspace" "this" {
  capacity_id  = data.fabric_capacity.this.id
  display_name = var.workspace_name
}

# Expose useful outputs to calling modules.
output "capacity" {
  description = "Fabric capacity details including identifiers."
  value       = data.fabric_capacity.this
}

output "workspace" {
  description = "Fabric workspace resource output."
  value       = fabric_workspace.this
}
