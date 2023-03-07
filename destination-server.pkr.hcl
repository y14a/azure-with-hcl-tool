packer {
  required_plugins {
    azure = {
      version = ">= 1.4.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

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
  sensitive = true
}

variable "name" {
  type = string
  default = "nginx-server"
}
variable "location" {
  type = string
  default = "japaneast"
}
variable "artifact_resource_group_name" {
  type = string
  default = "packer-artifact"
}
variable "version_name" {
  type = string
  default = ""
}
variable "delimiter" {
  type = string
  default = "-"
}
variable "manifest" {
  type        = string
  description = "(optional) manifest file for built image"
  default     = ""
}

locals {
  version_name = var.version_name != "" ? var.version_name : formatdate("YYYYMMDDHHmmss", timestamp())
  manifest = var.manifest != "" ? var.manifest : "${var.name}.manifest.json"
  managed_image_name = "${var.name}${var.delimiter}${local.version_name}"
}

source "azure-arm" "test_server" {
  # credentials
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret

  # Workspace for building image


  # Source image from Marketplace
  image_offer                       = "UbuntuServer"
  image_publisher                   = "Canonical"
  image_sku                         = "16.04-LTS"

  # Destination of built image
  location                          = var.location
  managed_image_name                = local.managed_image_name
  managed_image_resource_group_name = var.artifact_resource_group_name
  os_type                           = "Linux"
  vm_size                           = "Standard_DS2_v2"
}

build {
  sources = ["source.azure-arm.test_server"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update", 
      "sudo apt-get upgrade -y", 
      "sudo apt-get -y install nginx jq curl",
      "sudo systemctl enable nginx"
    ]
  }

  provisioner "file" {
    sources = [
      "default.conf"
    ]
    destination = "/tmp/"
  }

  provisioner "shell" {
    inline = [
      "sed -E '/access_log|error_log/ s/./#&/' /etc/nginx/nginx.conf",
      "sudo cp /tmp/default.conf /etc/nginx/conf.d/",
      "sudo rm /etc/nginx/sites-enabled/default"
    ]
  }

  post-processor "manifest" {
    output = local.manifest
    strip_path = false
    custom_data = {
      azurerm_shared_image_version = {
        name = local.version_name
      }
    }
  }
}