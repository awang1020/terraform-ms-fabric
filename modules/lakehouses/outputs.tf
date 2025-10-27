############################################################
# Lakehouses module outputs
############################################################

output "lakehouses" {
  description = "Map of medallion layer to lakehouse details (id and name)."
  value = {
    for k, lh in fabric_lakehouse.this :
    k => {
      id   = lh.id
      name = lh.display_name
    }
  }
}

