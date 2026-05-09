# terraform/week6/main.tf
# ─────────────────────────────────────────────────────────────────────────────
# CIS 410 — Week 6: First Terraform Configuration
# Creates two Google Cloud Storage buckets in your GCP project.
#
# HOW TO USE:
#   1. Copy your Project ID into terraform.tfvars (see variables.tf)
#   2. terraform init
#   3. terraform plan        (should show: 2 to add)
#   4. terraform apply       (type yes)
#   5. terraform destroy     (type yes — removes both buckets)
#   6. terraform apply       (recreate — Destroy and Rebuild principle)
#
# BUCKETS CREATED:
#   cis410-yourname-tfstate  — Terraform remote state backend (Week 7)
#   cis410-yourname-logs     — Application and infra logs (Week 9)
# ─────────────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ── Bucket 1: Terraform state ─────────────────────────────────────────────────
# Stores Terraform state files. Becomes the remote backend in Week 7.
# Versioning keeps previous state versions for recovery.
resource "google_storage_bucket" "tf_state" {
  name          = "${var.project_id}-tfstate"
  location      = "US"
  force_destroy = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 5
    }
    action {
      type = "Delete"
    }
  }
}

# ── Bucket 2: Logs ────────────────────────────────────────────────────────────
# Stores application and infrastructure logs. Used in Week 9.
# Objects older than 30 days are automatically deleted.
resource "google_storage_bucket" "logs" {
  name          = "${var.project_id}-logs"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}
