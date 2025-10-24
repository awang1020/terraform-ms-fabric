############################################################
# Root module outputs for quick reference after deployment.
############################################################

# Details of the Fabric capacity including identifiers and metadata.
output "fabric_capacity" {
  value       = module.fabric.capacity
  description = "Metadata describing the deployed Fabric capacity."
}

# Details of the Fabric workspace including identifiers and metadata.
output "fabric_workspace" {
  value       = module.fabric.workspace
  description = "Metadata describing the deployed Fabric workspace."
}

# Resource group reference for integration with other stacks.
output "resource_group" {
  value = {
    id   = module.resource_group.id
    name = module.resource_group.name
  }
  description = "Reference information for the hosting resource group."
}
