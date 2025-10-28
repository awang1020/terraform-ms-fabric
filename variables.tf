############################################################
# Root module variable definitions
############################################################

variable "client" {
  description = "Client or tenant identifier used as the naming prefix (lowercase letters, numbers, hyphens)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.client))
    error_message = "client must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment suffix (dev, test, or prod)."
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], lower(var.environment))
    error_message = "environment must be one of: dev, test, prod."
  }
}

variable "location" {
  description = "Azure region where the infrastructure is deployed."
  type        = string
  default     = "francecentral"
}

variable "fabric_capacity_sku" {
  description = "Fabric capacity SKU size (for example, F2, F4, F8)."
  type        = string
  default     = "F2"
}

variable "subscription_id" {
  description = "Azure subscription identifier used by the providers."
  type        = string
}

# Pass-through for workspace group role assignments
variable "workspace_group_assignments" {
  description = "List of Azure AD group role assignments across Fabric workspaces. If workspaces is empty or omitted, applies to all created workspaces. Prefer group_object_id; group_display_name lookup is discouraged and may be removed in a future version."
  type = list(object({
    group_object_id    = optional(string)
    group_display_name = optional(string)
    role               = string
    workspaces         = optional(list(string), [])
  }))
  default = []
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags communs appliqués à la ressource"
}

variable "enable_schemas" {
  description = "Whether to enable schemas feature on each lakehouse."
  type        = bool
  default     = true
}

# Artifact naming usage tokens for DEV workspace artifacts
variable "artifacts_dataflow_usage" {
  description = "Usage token for Dataflow name (pattern: dataflow_<usage>_<workspace>)."
  type        = string
  default     = "ingest"
}

variable "artifacts_pipeline_usage" {
  description = "Usage token for Data Pipeline name (pattern: data_pipeline_<usage>_<workspace>)."
  type        = string
  default     = "orchestrate"
}

variable "artifacts_notebook_usage" {
  description = "Usage token for Notebook name (pattern: notebook_<usage>_<workspace>)."
  type        = string
  default     = "explore"
}

# Deployment pipeline role assignments
variable "deployment_pipeline_role_assignments" {
  description = "List of AAD role assignments for the deployment pipeline. Only role 'Admin' is supported. Prefer object IDs: group_object_id for groups and user_object_id for users. Display-name/UPN lookup is discouraged and may be removed in a future version."
  type = list(object({
    role                = string              # Only 'Admin' is supported for deployment pipelines
    principal_type      = string              # "Group" or "User"
    group_object_id     = optional(string)
    group_display_name  = optional(string)
    user_object_id      = optional(string)
    user_principal_name = optional(string)
  }))
  default = []
  validation {
    condition     = alltrue([for a in var.deployment_pipeline_role_assignments : lower(a.role) == "admin"])
    error_message = "deployment pipeline role assignments must use role 'Admin' only."
  }
}
