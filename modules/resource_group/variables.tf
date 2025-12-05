###############################################
# Variables for the resource group module.
###############################################

variable "name" {
  description = "Name of the Azure resource group."
  type        = string
}

variable "location" {
  description = "Azure region where the resource group is created."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resource group."
  type        = map(string)
  default     = {}
}

