############################################################
# Artifacts module: Dataflow Gen2, Data Pipeline, Notebook
############################################################

terraform {
  required_providers {
    fabric = {
      source = "microsoft/fabric"
    }
  }
}

locals {
  # Replace hyphens for readability and keep letters/numbers/underscores
  workspace_slug           = replace(var.workspace_name, "-", "_")
  sanitized_workspace_name = join("", regexall("[A-Za-z0-9_]", local.workspace_slug))
}

resource "fabric_dataflow" "this" {
  workspace_id = var.workspace_id
  display_name = "df_${var.dataflow_usage}_${local.sanitized_workspace_name}"
}

resource "fabric_data_pipeline" "this" {
  workspace_id = var.workspace_id
  display_name = "pl_${var.pipeline_usage}_${local.sanitized_workspace_name}"
}

resource "fabric_notebook" "this" {
  workspace_id = var.workspace_id
  display_name = "nb_${var.notebook_usage}_${local.sanitized_workspace_name}"
}

