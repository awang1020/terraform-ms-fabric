###############################################
# Variables for the shortcut module.
###############################################
variable "resource_group_name" {
  description = "resource group name"
  type = string
}

variable "resource_group_location" {
  description = "resource group location"
  type = string
}

variable "storage_account_name" {
  description = "Name of the storage account to create."
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type = string
}

variable "workspace_id" {
  description = "ID of the Fabric workspace."
  type        = string
}

variable "lakehouse_id" {
  description = "ID of the lakehouse item in the workspace."
  type        = string
}

variable "shortcut_name" {
  description = "Name of the shortcut"
  type = string
}

# variable "table_name" {
#   description = "Name of the table to create in the lakehouse."
#   type        = string
#   default     = "sales"
# }

variable "notebook_name" {
  description = "Name of the notebook to create"
  type = string
  default = "terraform Demo"
}

variable "client_slug" {
  description = "Client slug for naming conventions"
  type        = string
}