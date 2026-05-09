# terraform/week6/variables.tf
# ─────────────────────────────────────────────────────────────────────────────
# Set values in terraform.tfvars — do NOT commit that file to GitHub.
# ─────────────────────────────────────────────────────────────────────────────

variable "project_id" {
  description = "cis410-asefa"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "us-central1"
}
