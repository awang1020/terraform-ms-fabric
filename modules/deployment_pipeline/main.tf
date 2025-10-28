############################################################
# Deployment Pipeline module (Microsoft Fabric provider)
############################################################

terraform {
  required_providers {
    fabric = {
      source = "microsoft/fabric"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

resource "fabric_deployment_pipeline" "this" {
  display_name = var.name

  stages = [
    {
      order        = 1
      display_name = "Development"
      workspace_id = var.dev_workspace_id
      description  = "DEV stage"
      is_public    = false
    },
    {
      order        = 2
      display_name = "Test"
      workspace_id = var.test_workspace_id
      description  = "TEST stage"
      is_public    = false
    },
    {
      order        = 3
      display_name = "Production"
      workspace_id = var.prod_workspace_id
      description  = "PROD stage"
      is_public    = false
    }
  ]
}

# ------------------------------------------------------------
# Optional role assignments on the deployment pipeline
# ------------------------------------------------------------
locals {
  # Resolve group display names and user UPNs if supplied
  group_names_for_lookup = toset([
    for a in var.pipeline_role_assignments : a.group_display_name
    if lower(a.principal_type) == "group" && try(a.group_object_id, "") == "" && try(a.group_display_name, "") != ""
  ])

  user_upns_for_lookup = toset([
    for a in var.pipeline_role_assignments : a.user_principal_name
    if lower(a.principal_type) == "user" && try(a.user_object_id, "") == "" && try(a.user_principal_name, "") != ""
  ])
}

data "azuread_group" "groups_by_name" {
  for_each     = local.group_names_for_lookup
  display_name = each.key
}

data "azuread_user" "users_by_upn" {
  for_each            = local.user_upns_for_lookup
  user_principal_name = each.key
}

locals {
  role_assignments_resolved = [
    for a in var.pipeline_role_assignments : {
      key = "${lower(a.principal_type)}:${lower(a.role)}:${coalesce(
        try(a.group_display_name, null),
        try(a.group_object_id, null),
        try(a.user_principal_name, null),
        try(a.user_object_id, null)
      )}"
      role           = a.role
      principal_type = a.principal_type
      principal_id   = try(coalesce(
        try(a.group_object_id, null),
        try(data.azuread_group.groups_by_name[a.group_display_name].object_id, null),
        try(a.user_object_id, null),
        try(data.azuread_user.users_by_upn[a.user_principal_name].object_id, null)
      ), null)
    }
    if (
      (lower(a.principal_type) == "group" && (
        try(a.group_object_id, "") != "" || try(a.group_display_name, "") != ""
      )) ||
      (lower(a.principal_type) == "user" && (
        try(a.user_object_id, "") != "" || try(a.user_principal_name, "") != ""
      ))
    )
  ]

  role_assignments_map = {
    for r in local.role_assignments_resolved :
    r.key => {
      role           = r.role
      principal_type = r.principal_type
      principal_id   = r.principal_id
    }
    if r.principal_id != null
  }
}

resource "fabric_deployment_pipeline_role_assignment" "this" {
  for_each               = local.role_assignments_map
  deployment_pipeline_id = fabric_deployment_pipeline.this.id
  role                   = each.value.role
  principal = {
    id   = each.value.principal_id
    type = each.value.principal_type
  }
}
