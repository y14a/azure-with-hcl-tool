resource "azurerm_resource_group" "artifact" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_shared_image_gallery" "main" {
  resource_group_name = azurerm_resource_group.artifact.name
  location            = var.location
  tags                = var.tags
  name                = var.gallery_name
}

resource "azurerm_shared_image" "nginx_server" {
  resource_group_name    = azurerm_resource_group.artifact.name
  location               = var.location
  tags                   = var.tags
  name                   = "nginx-server"
  gallery_name           = azurerm_shared_image_gallery.main.name
  disk_types_not_allowed = []

  identifier {
    offer     = "default"
    publisher = "default"
    sku       = "default"
  }
  os_type = "Linux"
}

module "my_image" {
  source = "./modules/packer"

  client_secret = var.client_secret

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = "nginx-server"
  gallery_name        = azurerm_shared_image_gallery.main.name

  trigger_files = [
    "${path.module}/default.conf",
  ]
  depends_on = [
    azurerm_resource_group.artifact,
  ]
}
