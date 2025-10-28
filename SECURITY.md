# Security and Compliance Guide

This repository provisions Microsoft Fabric resources on Azure with Terraform. This guide documents security practices, least‑privilege RBAC, identity guidance, state management, and recommended guardrails for production use.

## Identity and Permissions
- Prefer AAD object IDs
  - Use `group_object_id` for groups and `user_object_id` for users in all inputs.
  - Avoid display names and UPNs for role assignment inputs; they are mutable and not unique. Name‑based lookups remain for compatibility but may be removed.
- Least‑privilege Azure RBAC
  - Resource Group: assign `Contributor` (avoid `Owner`) only when needed. Readers can be used for visibility only.
  - Fabric Capacity: rely on Fabric administrators via provider (`administration_members`) and use Azure `Contributor` only when Azure‑level actions are required. Avoid `Owner` and `User Access Administrator`.
  - Scope assignments narrowly to the specific resource or RG; avoid subscription‑level roles.
- Provider authentication
  - Local: authenticate with Azure CLI (`az login`).
  - CI/CD: use workload identity federation (OIDC) with short‑lived tokens instead of client secrets. Pin the tenant explicitly when multi‑tenant environments are possible.

## State and Secrets
- Do not commit TF state or real `.tfvars`. Use `terraform.tfvars` locally only.
- Use a remote backend (Azure Storage) with:
  - Encryption at rest, soft delete, blob versioning, and container immutability (as required).
  - Private endpoints and network restrictions.
  - RBAC for access; no shared keys in code. Use `az login`/OIDC for auth.
- Keep sensitive values in Key Vault or environment variables; do not store secrets in state.

## Policy and Guardrails
- Enforce Azure Policy:
  - Allowed locations and SKUs, required tags, deny public network access where applicable.
  - Deny assignment for unmanaged resources in protected RGs.
- Resource protection:
  - Apply `CanNotDelete` locks to critical resources (RG, capacity) where appropriate.
- Logging and monitoring:
  - Enable diagnostic settings to send platform logs/metrics to a Log Analytics workspace for auditability.

## Provider Management
- Providers are version‑pinned for reproducibility. Review and update routinely.
- The Fabric provider may use preview features; validate compliance requirements before production use.

## CI/CD and Change Control
- Required checks:
  - `terraform fmt -recursive`, `terraform validate`.
  - Static analysis: `tflint`, `tfsec` or `checkov`.
  - Plan/apply gates with manual approval for production; avoid `-auto-approve` in non‑interactive prod runs.
- Supply chain:
  - Use Dependabot/Renovate for provider updates.
  - Scan for committed secrets.

## Drift and Naming
- Names are derived from `client` and `environment`. If `client` changes, workspace names change. Update existing names (or import/destroy/recreate) to prevent drift and conflicts.

## Incident Response
- Keep state backups and enable blob versioning/soft delete for recovery.
- Use RBAC activity logs and diagnostic logs to investigate changes.

