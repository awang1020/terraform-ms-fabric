############################################################
# Lakehouses module variables
############################################################

variable "workspace_id" {
  description = "ID of the Fabric workspace where lakehouses will be created."
  type        = string
}

variable "workspace_name" {
  description = "Display name of the target workspace, used in lakehouse naming."
  type        = string
}

variable "layers" {
  description = "List of medallion layers to create (e.g., bronze, silver, gold)."
  type        = list(string)
  default     = ["bronze", "silver", "gold"]
}

variable "name_prefix" {
  description = "Prefix for lakehouse names. Final pattern is <prefix>_<layer>_<workspace_name>."
  type        = string
  default     = "lh"
}

variable "enable_schemas" {
  description = "Whether to enable schemas feature on each lakehouse."
  type        = bool
  default     = true
}
