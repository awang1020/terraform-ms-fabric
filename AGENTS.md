# Repository Guidelines

## Project Structure & Module Organization
- Root Terraform: `main.tf`, `providers.tf`, `variables.tf`, `outputs.tf`.
- Modules: `modules/resource_group` (Azure RG) and `modules/fabric` (Fabric capacity + workspace).
- Vars: `terraform.tfvars.example` shows expected inputs; copy to `terraform.tfvars` for local runs.
- Docs: `README.md` for setup prerequisites.

## Build, Test, and Development Commands
- Initialize providers: `terraform init`
- Format code: `terraform fmt -recursive` (run before commits)
- Static checks: `terraform validate`
- Preview changes: `terraform plan -var-file="terraform.tfvars"`
- Apply changes: `terraform apply -var-file="terraform.tfvars"`
- Destroy stack: `terraform destroy -var-file="terraform.tfvars"`
Prereq: login with `az login` and ensure the `subscription_id` variable matches your target subscription.

## Coding Style & Naming Conventions
- Indentation: 2 spaces; wrap long arguments across lines.
- Filenames: keep Terraform defaults (`main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`).
- Identifiers: use lower_snake_case for variables/outputs; prefix resource names for clarity (e.g., `rg-<name>`, `ws-<name>`).
- Modules: keep input/output names stable; document changes in `README.md`.
- Run `terraform fmt` before opening a PR.

## Testing Guidelines
- Mandatory: `terraform fmt -recursive` and `terraform validate` must pass.
- Plans should be idempotent after first apply (no-op plans indicate health).
- For risky changes, attach the `terraform plan` output in the PR.
- No unit tests in this repo; consider Terratest in a separate harness if needed.

## Commit & Pull Request Guidelines
- Commits: short, imperative subjects (e.g., "Add fabric capacity output"). Group related changes.
- PRs must include: purpose, notable module/interface changes, sample `plan` snippet, and any breaking notes.
- Link issues where relevant. Add screenshots for Azure Portal results when useful.

## Security & Configuration Tips
- Do not commit state, secrets, or `.tfvars`. Use `terraform.tfvars` locally; store shared state in a remote backend (e.g., Azure Storage) if collaborating.
- Authenticate via Azure CLI (`az login`) and confirm the active subscription (`az account show`).

## Agent-Specific Instructions
- Keep changes minimal and localized; avoid renaming module inputs/outputs unless required.
- Preserve existing structure and comments; update docs when behavior changes.
