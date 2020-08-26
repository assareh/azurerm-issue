variable "location" {
  description = "Azure location in which to create resources"
  default     = "West US 2"
}

variable "prefix" {
  description = "Name prefix to add to the resources"
  default     = "azurerm-issue"
}

variable "admin_username" {
  description = "Administrator user name for linux"
  default     = "admin"
}

// Tags
variable "ttl" {
  description = "value of ttl tag on cloud resources"
  default     = "1"
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Owner   = "user"
    Purpose = "Demo Terraform and Vault"
    TTL     = var.ttl #hours
    # Optional
    Terraform = "true" # true/false
    TFE       = "true" # true/false
  }
}
