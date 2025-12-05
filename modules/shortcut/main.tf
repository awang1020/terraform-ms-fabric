###############################################
# Shortcut module
# Creates a Fabric connection to Azure Storage
# and establishes shortcuts to the CSV data file.
###############################################

terraform {
  required_providers {
    fabric = {
      source = "microsoft/fabric"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}


# Create a shortcut in the lakehouse pointing to the CSV file
resource "fabric_shortcut" "this" {
  workspace_id = var.workspace_id
  item_id      = var.lakehouse_id

  name = var.shortcut_name
  path = "Files"

  target = {
    azure_blob_storage = {
      connection_id = fabric_connection.storage_account_key.id
      location      = "https://${var.storage_account_name}.blob.core.windows.net"
      subpath       = "/${var.container_name}"
    }
  }
}

resource "fabric_notebook" "notebook2" {
  display_name              = var.notebook_name
  workspace_id              = var.workspace_id
  definition_update_enabled = false
  format                    = "ipynb"
  definition = {
    "notebook-content.ipynb" = {
      source = "${path.module}/data/notebook/demo.ipynb.tmpl"
    }
  }
}

# Create a storage account within the resource group
resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a storage container for data
resource "azurerm_storage_container" "data" {
  name                  = var.container_name
  storage_account_id  = azurerm_storage_account.this.id
  container_access_type = "private"
}

locals {
  order_files = fileset("${path.module}/data/orders", "*")
}

# Upload the sales.csv file to the storage container
resource "azurerm_storage_blob" "order_files" {
  for_each = local.order_files

  name                   = each.value
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "${path.module}/data/orders/${each.value}"
}

resource "fabric_data_pipeline" "example7" {
  display_name = "terraform  test 7"
  workspace_id              = var.workspace_id
  definition_update_enabled = false
  format = "Default"
  definition = {
    "pipeline-content.json" = {
      source = "${path.module}/data/pipeline/pipeline-content.json"
      tokens = {
        "connectionName" = "lh_bronze_customer_DEV"
        "workspaceId" = var.workspace_id
        "artifactId"  = "bea92c0a-46b8-4e14-92ed-f66b5b7839ac"
        "connection"  = "9a56af28-8c7f-4f37-a31c-ed4eb26fb3b2"
        "tableName"      = "xxx"
        "blobName"      = "2019.csv"
        "containerName" = "orders"
      }
    }
  }
}
# Retrieve the storage account details
data "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Create a Fabric connection to the Azure Storage account
resource "fabric_connection" "storage_account_key" {
  display_name      = "my-storage-connection"
  connectivity_type = "ShareableCloud"
  privacy_level     = "Organizational"

  # --- Connection details ---
  connection_details = {
    type            = "AzureBlobs"                      # Type de connecteur
    creation_method = "AzureBlobs"             # Méthode Power Query utilisée
    parameters = [
      {
        name  = "account"
        value = azurerm_storage_account.this.name                 # Nom du storage account
      },
      {
        name  = "domain"
        value = "blob.core.windows.net"                     # Domaine standard
      }
    ]
  }

  # --- Credentials (Account Key) ---
  credential_details = {
    connection_encryption = "NotEncrypted"
    credential_type       = "Key"
    single_sign_on_type   = "None"
    skip_test_connection  = false

    key_credentials = {
      key_wo         = data.azurerm_storage_account.this.primary_access_key
      key_wo_version = 1                               # Version du secret
    }
  }
}


# resource "null_resource" "create_sales_table" {
#   provisioner "local-exec" {
#     interpreter = ["PowerShell", "-Command"]
#     command = <<EOT
#     $TOKEN = (az account get-access-token --resource https://api.fabric.microsoft.com --query accessToken -o tsv)

#     $Body = @{
#         relativePath = "Files/${var.shortcut_name}/${var.blob_name}"
#         pathType = "File"
#         mode = "overwrite"
#         formatOptions = @{
#             header = "true"
#             delimiter = ","
#             format = "CSV"
#         }
#     } | ConvertTo-Json -Depth 5

#     Invoke-RestMethod -Uri "https://api.fabric.microsoft.com/v1/workspaces/${var.workspace_id}/lakehouses/${var.lakehouse_id}/tables/${var.table_name}/load" `
#     -Method POST `
#     -Headers @{Authorization = "Bearer $TOKEN"; "Content-Type" = "application/json"} `
#     -Body $Body
#     EOT
#     }
    
#     depends_on = [fabric_shortcut.this]
    
#     triggers = {
#         always_run = timestamp()
#     }
# }