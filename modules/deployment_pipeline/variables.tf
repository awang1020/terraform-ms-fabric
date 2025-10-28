############################################################
# Deployment Pipeline module variables
############################################################

variable "name" {
  description = "Name for the Fabric Deployment Pipeline."
  type        = string
}

// Description is not required by the provider resource and is omitted
// to keep the schema minimal and provider-compatible.

variable "dev_workspace_id" {
  description = "Fabric workspace ID for the Development stage."
  type        = string
}

variable "test_workspace_id" {
  description = "Fabric workspace ID for the Test stage."
  type        = string
}

variable "prod_workspace_id" {
  description = "Fabric workspace ID for the Production stage."
  type        = string
}

variable "pipeline_role_assignments" {
  description = "List of AAD role assignments for the deployment pipeline. Only role 'Admin' is supported. Prefer object IDs (group_object_id, user_object_id). Display-name/UPN lookup is discouraged and may be removed in a future version."
  type = list(object({
    role                = string              # Only 'Admin' is supported for deployment pipelines
    principal_type      = string              # "Group", "User", "ServicePrincipal", "ServicePrincipalProfile"
    group_object_id     = optional(string)
    group_display_name  = optional(string)
    user_object_id      = optional(string)
    user_principal_name = optional(string)
  }))
  default = []
  validation {
    condition     = alltrue([for a in var.pipeline_role_assignments : lower(a.role) == "admin"])
    error_message = "deployment pipeline role assignments must use role 'Admin' only."
  }
}
