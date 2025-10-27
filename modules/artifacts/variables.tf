############################################################
# Artifacts (Dataflow Gen2, Data Pipeline, Notebook) variables
############################################################

variable "workspace_id" {
  description = "ID of the Fabric workspace where artifacts will be created."
  type        = string
}

variable "workspace_name" {
  description = "Display name of the target workspace, used in naming."
  type        = string
}

variable "dataflow_usage" {
  description = "Usage qualifier for the Dataflow name (pattern: dataflow_<usage>_<workspace>)."
  type        = string
  default     = "ingest"
}

variable "pipeline_usage" {
  description = "Usage qualifier for the Data Pipeline name (pattern: data_pipeline_<usage>_<workspace>)."
  type        = string
  default     = "orchestrate"
}

variable "notebook_usage" {
  description = "Usage qualifier for the Notebook name (pattern: notebook_<usage>_<workspace>)."
  type        = string
  default     = "explore"
}

