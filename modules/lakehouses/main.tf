############################################################
# Lakehouses module
# Creates one lakehouse per medallion layer in a workspace
############################################################

terraform {
  required_providers {
    fabric = {
      source = "microsoft/fabric"
    }
  }
}

locals {
  layer_set = toset([for l in var.layers : lower(l)])
  # Convert hyphens to underscores to retain readability, then strip others
  workspace_slug           = replace(var.workspace_name, "-", "_")
  sanitized_workspace_name = join("", regexall("[A-Za-z0-9_]", local.workspace_slug))
}

resource "fabric_lakehouse" "this" {
  for_each     = local.layer_set
  workspace_id = var.workspace_id
  display_name = "${var.name_prefix}_${each.key}_${local.sanitized_workspace_name}"

  configuration = {
    enable_schemas = var.enable_schemas
  }
}
