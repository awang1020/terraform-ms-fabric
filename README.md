# Fabric Capacity Création d'un groupe de ressources, une capacité Fabric et un espace de travail Fabric

## Input Variables (modifier la région et la taille SKU dans variables.tf)

| Name                  | Description                     | Type   | Default       | Required |
|-----------------------|---------------------------------|--------|---------------|:--------:|
| `name`                | Name of the solution            | string |               |   true   |
| `location`            | Location of the Azure resources | string | francecentral |  false   |
| `fabric_capacity_sku` | Fabric Capacity SKU name        | string | F2            |  false   |
| `subscription_id`     | The Azure subscription ID       | string |               |   true   |

## Output Values

| Name               | Description             |
|--------------------|-------------------------|
| `fabric_capacity`  | Fabric Capacity object  |
| `fabric_workspace` | Fabric Workspace object |

## Usage

Execute example with the following commands:

```shell
terraform init
terraform apply
```