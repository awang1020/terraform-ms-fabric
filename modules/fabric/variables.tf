###############################################
# Variables for the Fabric module.
###############################################

variable "capacity_name" {
  description = "Name of the Microsoft Fabric capacity."
  type        = string
}

variable "workspace_name" {
  description = "Display name for the Microsoft Fabric workspace. Used when `workspace_names` is not set."
  type        = string
  default     = null
}

variable "workspace_names" {
  description = "List of Fabric workspace display names to create on the same capacity. If provided, supersedes `workspace_name`."
  type        = list(string)
  default     = []
}

variable "location" {
  description = "Azure region used for the Fabric capacity."
  type        = string
}

variable "capacity_sku" {
  description = "SKU identifier for the Fabric capacity (for example, F2)."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where the capacity will reside."
  type        = string
}

variable "administrator_upns" {
  description = "List of Fabric administrator user principal names."
  type        = list(string)
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags communs appliqués à la ressource"
}

# Optional group role assignments to workspaces
variable "workspace_group_assignments" {
  description = "List of Azure AD group role assignments across Fabric workspaces. If workspaces is empty or omitted, applies to all created workspaces. Prefer group_object_id; group_display_name lookup is discouraged and may be removed in a future version."
  type = list(object({
    group_object_id    = optional(string)
    group_display_name = optional(string)
    role               = string # e.g., Admin, Member, Contributor, Viewer
    workspaces         = optional(list(string), [])
  }))
  default = []
}
