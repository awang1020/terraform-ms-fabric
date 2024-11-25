variable "name" {
  description = "Name of the solution"
  type        = string
}

# Modify the location if needed - RGPD 
variable "location" {
  description = "Location of the Azure resources"
  type        = string
  default     = "francecentral"
}

# Modify the size if needed - F64 for premium 
variable "fabric_capacity_sku" {
  description = "Fabric Capacity SKU name"
  type        = string
  default     = "F2"
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}
