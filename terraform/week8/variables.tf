
# terraform/week8/variables.tf


variable "project_id" {

  description = "cis410-asefa"

  type        = string

}


variable "region" {

  description = "GCP region"

  type        = string

  default     = "us-central1"

}


variable "container_image" {

  description = "Full Artifact Registry image path including commit SHA tag"

  type        = string

  # Format: us-central1-docker.pkg.dev/PROJECT_ID/cis410-app/flask-app:COMMIT_SHA

}