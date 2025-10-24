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

## ⚙️ Configuration des variables
Copiez `terraform.tfvars.example` vers `terraform.tfvars` et adaptez les valeurs :
```hcl
name                = "my-fabric-demo"
location            = "francecentral"
fabric_capacity_sku = "F2"
subscription_id     = "00000000-0000-0000-0000-000000000000"
```
> ⚠️ Ne versionnez jamais votre fichier `terraform.tfvars` contenant des identifiants réels.

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
