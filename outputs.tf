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

# Map of created Fabric workspaces (when multiple are created).
output "fabric_workspaces" {
  value       = module.fabric.workspaces
  description = "Map of Fabric workspaces created on the capacity."
}

# Resource group reference for integration with other stacks.
output "resource_group" {
  value = {
    id   = module.resource_group.id
    name = module.resource_group.name
  }
  description = "Reference information for the hosting resource group."
}

# Lakehouses created in the DEV workspace (IDs and names)
output "dev_lakehouses" {
  value       = module.lakehouses_dev.lakehouses
  description = "Map of medallion layer to lakehouse {id, name} for the DEV workspace."
}

# Artifacts created in the DEV workspace (IDs and names)
output "dev_artifacts" {
  description = "Dataflow Gen2, Data Pipeline, and Notebook created in DEV with {id, name}."
  value = {
    dataflow = module.artifacts_dev.dataflow
    pipeline = module.artifacts_dev.pipeline
    notebook = module.artifacts_dev.notebook
  }
}
