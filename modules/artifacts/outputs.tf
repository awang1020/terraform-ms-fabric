############################################################
# Artifacts module outputs
############################################################

output "dataflow" {
  description = "Dataflow Gen2 details (id and name)."
  value = {
    id   = fabric_dataflow.this.id
    name = fabric_dataflow.this.display_name
  }
}

output "pipeline" {
  description = "Data Pipeline details (id and name)."
  value = {
    id   = fabric_data_pipeline.this.id
    name = fabric_data_pipeline.this.display_name
  }
}

output "notebook" {
  description = "Notebook details (id and name)."
  value = {
    id   = fabric_notebook.this.id
    name = fabric_notebook.this.display_name
  }
}

