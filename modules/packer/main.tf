data "azurerm_client_config" "main" {

}

data "local_file" "trigger_file" {
  for_each = toset(var.trigger_files)
  filename = each.value
}

locals {
  triggers = merge(
    { for v in data.local_file.trigger_file : v.filename => md5(v.content) },
    { resource_group_name = var.resource_group_name }
  )
  manifest_file = "${var.name}.manifest.json"
  build_envvar = {
    PKR_VAR_subscription_id              = data.azurerm_client_config.main.subscription_id
    PKR_VAR_tenant_id                    = data.azurerm_client_config.main.tenant_id
    PKR_VAR_client_id                    = data.azurerm_client_config.main.client_id
    PKR_VAR_client_secret                = var.client_secret
    PKR_VAR_artifcat_resource_group_name = var.resource_group_name
    PKR_VAR_name                         = var.name
    PKR_VAR_manifest                     = local.manifest_file
  }
}


resource "null_resource" "packer_build" {
  provisioner "local-exec" {
    command     = "packer build ${var.packer_workdir}"
    environment = local.build_envvar
  }
  triggers = local.triggers
}

data "local_file" "manifest" {
  filename = "${path.root}/${local.manifest_file}"
  depends_on = [
    null_resource.packer_build
  ]
}

locals {
  manifest      = jsondecode(data.local_file.manifest.content)
  last_run_uuid = local.manifest.last_run_uuid
  last_run      = local.manifest.builds[index(local.manifest.builds.*.packer_run_uuid, local.last_run_uuid)]
  images = { for o in local.manifest.builds :
    o.artifact_id => reverse(split("/", o.artifact_id))[0]
  }

  version_target = var.enable_versionning ? local.images : {}
}

resource "azurerm_shared_image_version" "versions" {
  gallery_name        = var.gallery_name
  location            = var.location
  resource_group_name = var.resource_group_name

  target_region {
    name                   = var.location
    regional_replica_count = var.regional_replica_count
    storage_account_type   = var.storage_account_type
  }

  for_each = local.version_target

  managed_image_id = each.key
  name             = each.value.version_name
  image_name       = each.value.image_name
}
