############################################################
# Deployment Pipeline module outputs
############################################################

output "id" {
  description = "Resource ID of the Deployment Pipeline."
  value       = fabric_deployment_pipeline.this.id
}

output "name" {
  description = "Name of the Deployment Pipeline."
  value       = fabric_deployment_pipeline.this.display_name
}

output "role_assignments" {
  description = "Map of deployment pipeline role assignments with principal and role details."
  value = {
    for k, v in fabric_deployment_pipeline_role_assignment.this :
    k => {
      id             = v.id
      role           = v.role
      principal_id   = v.principal.id
      principal_type = v.principal.type
    }
  }
}
