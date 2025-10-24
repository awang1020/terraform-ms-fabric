###############################################
# Variables for the Fabric module.
###############################################

variable "capacity_name" {
  description = "Name of the Microsoft Fabric capacity."
  type        = string
}

variable "workspace_name" {
  description = "Display name for the Microsoft Fabric workspace."
  type        = string
}

variable "location" {
  description = "Azure region used for the Fabric capacity."
  type        = string
}

variable "capacity_sku" {
  description = "SKU identifier for the Fabric capacity (for example, F2)."
  type        = string
}

variable "resource_group_id" {
  description = "Resource group identifier where the capacity will reside."
  type        = string
}

variable "administrator_upns" {
  description = "List of Fabric administrator user principal names."
  type        = list(string)
}
