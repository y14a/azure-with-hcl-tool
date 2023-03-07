
output "last_image_id" {
  value = local.last_run.artifact_id
}

output "image_ids" {
  value = local.manifest.builds.*.artifact_id
}
