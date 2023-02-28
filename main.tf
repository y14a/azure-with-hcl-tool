resource "azurerm_resource_group" "packer_artifact" {
  name     = var.artifact_resource_group_name
  location = var.location
  tags     = var.tags
}

data "local_file" "packer_file" {
  filename = "${path.module}/destination-server.pkr.hcl"
}
data "local_file" "nginx_conf" {
  filename = "${path.module}/default.conf"
}

resource "null_resource" "packer_build" {
  provisioner "local-exec" {
    command = "packer build ."
    environment = {
      PKR_VAR_subscription_id              = var.subscription_id
      PKR_VAR_tenant_id                    = var.tenant_id
      PKR_VAR_client_id                    = var.client_id
      PKR_VAR_client_secret                = var.client_secret
      PKR_VAR_artifcat_resource_group_name = var.artifact_resource_group_name
    }
  }
  triggers = {
    packer_file = data.local_file.packer_file.id
    nginx_conf  = data.local_file.nginx_conf.id
  }
  depends_on = [
    azurerm_resource_group.packer_artifact
  ]
}
