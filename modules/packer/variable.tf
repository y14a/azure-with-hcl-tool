variable "client_secret" {
  type = string
}

variable "packer_workdir" {
  type        = string
  description = "(optional) working directory for packer build"
  default     = "."
}

variable "trigger_files" {
  type        = list(string)
  description = "(optional) describe your variable"
}

variable "resource_group_name" {
  type        = string
  description = "image and version resource group name"
}

variable "name" {
  type        = string
  description = "image name"
}

variable "location" {
  type        = string
  description = "image and version location"
}

variable "tags" {
  type        = map(string)
  description = "(optional) tags for image"
  default     = {}
}

variable "gallery_name" {
  type        = string
  description = "Azure Shared Gallery name to store image version"
}

variable "storage_account_type" {
  type        = string
  description = "(optional) type of storage storing image version replica (default Standard_LRS)"
  default     = "Standard_LRS"
}

variable "regional_replica_count" {
  type        = number
  description = "(optional) number of regional replica of image version (default 1)"
  default     = 1
}

variable "enable_versionning" {
  type        = bool
  description = "(optional) register version to gallery (default false)"
  default     = false
}
