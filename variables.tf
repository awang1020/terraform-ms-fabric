############################################################
# Root module variable definitions
############################################################

variable "name" {
  description = "Project suffix used when naming Fabric resources."
  type        = string
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
