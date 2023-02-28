# These variables will be shared with packer and terraform
variable "subscription_id" {
  type = string
}
variable "tenant_id" {
  type = string
}
variable "client_id" {
  type = string
}
variable "client_secret" {
  type = string
}

variable "artifact_resource_group_name" {
  type        = string
  description = "(optional) resource group name to store infra testing resource"
  default     = "test-artifact"
}

variable "location" {
  type        = string
  description = "(optional) location of resource group name to store infra testing resources"
  default     = "japaneast"
}

variable "tags" {
  type        = map(string)
  description = "(optional) tags for append any resource"
  default = {
    usage = "infra-testing"
  }
}
