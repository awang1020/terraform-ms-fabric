# Microsoft Fabric Terraform Deployment

## 🎯 Objectif du projet
Ce dépôt fournit une configuration Terraform modulaire pour déployer rapidement une infrastructure Microsoft Fabric sur Azure. Il crée un groupe de ressources, une capacité Fabric et un workspace associés afin d'offrir une base prête à l'emploi pour vos projets d'analytics.

## ✅ Prérequis
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.8
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) configuré et authentifié (`az login`)
- Droits Azure suffisants pour créer des groupes de ressources, des capacités Fabric et administrer Microsoft Fabric
- Providers Terraform utilisés :
  - `hashicorp/azurerm`
  - `Azure/azapi`
  - `hashicorp/azuread`
  - `microsoft/fabric`

### Installer Azure CLI sur son poste

#### Windows
1. Téléchargez le programme d'installation depuis la page officielle : [Azure CLI pour Windows](https://aka.ms/installazurecliwindows).
2. Exécutez le fichier `.msi` puis suivez l'assistant en conservant les options par défaut.
3. Ouvrez un nouveau terminal PowerShell et vérifiez l'installation :
   ```powershell
   az version
   ```

#### macOS
1. Installez Homebrew si ce n'est pas déjà fait : [Instructions officielles](https://brew.sh/index_fr).
2. Installez Azure CLI via Homebrew :
   ```bash
   brew update
   brew install azure-cli
   ```
3. Vérifiez l'installation :
   ```bash
   az version
   ```

#### Linux (Debian/Ubuntu)
1. Importez la clé Microsoft :
   ```bash
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```
2. Vérifiez l'installation :
   ```bash
   az version
   ```

> Pour d'autres distributions, consultez la [documentation officielle](https://learn.microsoft.com/cli/azure/install-azure-cli) qui détaille les paquets disponibles.

### Authentification à Azure
1. Ouvrez un terminal et exécutez :
   ```bash
   az login
   ```
2. Un navigateur s'ouvre : connectez-vous avec votre compte Azure disposant des droits nécessaires.
3. Pour les environnements sans interface graphique, utilisez :
   ```bash
   az login --use-device-code
   ```
   puis suivez les instructions affichées dans le terminal.
4. Vérifiez le compte actif :
   ```bash
   az account show --output table
   ```
5. Si plusieurs abonnements sont disponibles, sélectionnez celui à utiliser avec :
   ```bash
   az account set --subscription "<nom-ou-id-de-l-abonnement>"
   ```

> Les identifiants enregistrés par `az login` seront utilisés automatiquement par Terraform via les providers Azure.

## 🗂️ Structure du dépôt
```
.
├── main.tf                 # Module racine orchestrant les appels
├── providers.tf            # Déclaration des providers et versionnements
├── variables.tf            # Variables d'entrée du module racine
├── outputs.tf              # Informations exportées après déploiement
├── terraform.tfvars.example# Exemple de configuration utilisateur
├── modules/
│   ├── fabric/             # Provision de la capacité et du workspace Fabric
│   └── resource_group/     # Création du groupe de ressources Azure
└── .gitignore              # Fichiers exclus du contrôle de version
```

## Variables (tfvars)
- `client` (string, required)
  - Purpose: naming prefix for resources (client/tenant).
  - Allowed: lowercase letters, numbers, hyphens `[a-z0-9-]`.
- `environment` (string, required)
  - Purpose: deployment environment suffix.
  - Values: `dev`, `test`, `prod`.
- `location` (string, default `"francecentral"`)
  - Purpose: Azure region for the deployment.
- `fabric_capacity_sku` (string, default `"F2"`)
  - Purpose: Microsoft Fabric capacity size (e.g., `F2`, `F4`, `F8`).
- `subscription_id` (string, required)
  - Purpose: Azure subscription ID used by providers.
- `tags` (map(string), default `{}`)
  - Purpose: common tags applied to supported resources (e.g., RG, capacity).
  - Example: `{ environment = "dev", owner = "data-team" }`.
- `enable_schemas` (bool, default `true`)
  - Purpose: enable schemas on each created lakehouse.
  - Note: changing this forces lakehouse replacement.
- `workspace_group_assignments` (list(object), default `[]`)
  - Purpose: assign AAD group roles to Fabric workspaces.
  - Object: `{ group_object_id (opt), group_display_name (opt), role (string), workspaces (list(string), opt) }`.
  - If `workspaces` is empty, applies to all created workspaces.

Example tfvars
Copiez `terraform.tfvars.example` vers `terraform.tfvars` et adaptez les valeurs :
```hcl
client              = "acme"                  # string, required
environment         = "dev"                   # string: dev | test | prod
location            = "francecentral"         # string, default "francecentral"
fabric_capacity_sku = "F2"                     # string, default "F2"
subscription_id     = "00000000-0000-0000-0000-000000000000" # string

tags = {                                  # map(string), optional
  environment = "dev"
  owner       = "data-team"
}

enable_schemas = true                     # bool, default true

workspace_group_assignments = [           # list(object), optional
  {
    group_object_id = "<aad-group-object-id>" # or use group_display_name
    role            = "Contributor"           # Admin | Member | Contributor | Viewer
    workspaces      = ["<workspace-name>"]    # empty -> applies to all created workspaces
  }
]
```
> ⚠️ Ne versionnez jamais votre fichier `terraform.tfvars` contenant des identifiants réels.


## First-Time Apply Note
- On the first deployment, the Fabric module reads the capacity via data source by display name, which fails until the capacity exists.
- Run two targeted applies first, then continue normally:
  - `terraform apply -auto-approve -var-file="terraform.tfvars" -target module.resource_group.azurerm_resource_group.this`
  - `terraform apply -auto-approve -var-file="terraform.tfvars" -target module.fabric.azurerm_fabric_capacity.this`
  - `terraform plan -var-file="terraform.tfvars"`
  - `terraform apply -var-file="terraform.tfvars"`
- This is only needed once per environment.

## Lakehouses (DEV workspace)
- The configuration now provisions three Lakehouses in the DEV workspace following the Medallion architecture: bronze, silver, gold.
- Naming pattern: `lh_<layer>_<workspace_name_slug>` where the workspace name is adapted for Fabric constraints:
  - Hyphens in the workspace name are converted to underscores (e.g. `renaud-DEV` -> `renaud_DEV`).
  - Only letters, numbers, and underscores are kept.
  - Examples: `lh_bronze_renaud_DEV`, `lh_silver_renaud_DEV`, `lh_gold_renaud_DEV`.
- Outputs: `dev_lakehouses` returns a map keyed by layer with each lakehouse's `id` and `name`.
- Customization: 
  - Layers and name prefix are configurable in `modules/lakehouses` and via the call in `main.tf`.
  - Schemas feature can be toggled with `enable_schemas` (default: `true`).

### Enable Schemas
- Lakehouses are created with schemas enabled by default: `enable_schemas = true`.
- Changing `enable_schemas` forces replacement (destroy/create) of the lakehouses due to provider behavior.
- Example module call in `main.tf`:
  ```hcl
  module "lakehouses_dev" {
    source         = "./modules/lakehouses"
    workspace_id   = module.fabric.workspaces[local.dev_workspace_key].id
    workspace_name = local.dev_workspace_name
    layers         = ["bronze", "silver", "gold"]
    name_prefix    = "lh"
    enable_schemas = true
  }
  ```


## 🚀 Commandes principales
```bash
terraform init      # Télécharge les providers et initialise le backend local
terraform fmt       # Formate la configuration selon les standards HashiCorp
terraform validate  # Vérifie la syntaxe et les dépendances
terraform plan      # Prévisualise les ressources créées ou modifiées
terraform apply     # Applique les changements après confirmation
terraform destroy   # Supprime l'infrastructure créée
```

## 🔐 Bonnes pratiques
- **Gestion des secrets** : stockez les identifiants sensibles dans Azure Key Vault et référencez-les via des variables d'environnement ou un backend distant. Les valeurs sensibles ne doivent jamais être commitées.
- **Remote state** : configurez un backend distant (Azure Storage, Terraform Cloud, etc.) pour partager l'état entre équipes et sécuriser les verrous de déploiement.
- **Workspaces Terraform** : utilisez des workspaces (`terraform workspace new dev`) pour gérer plusieurs environnements à partir du même code tout en conservant des états isolés.
- **Revue de code** : passez systématiquement par des Pull Requests et des revues afin de conserver la traçabilité des évolutions d'infrastructure.

## 📚 Ressources utiles
- [Documentation Microsoft Fabric Terraform Provider](https://registry.terraform.io/providers/microsoft/fabric/latest/docs)
- [Référence AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Guides Terraform Azure](https://learn.microsoft.com/azure/developer/terraform/)
