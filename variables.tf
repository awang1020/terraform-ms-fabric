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
