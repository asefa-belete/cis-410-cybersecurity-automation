# terraform/week8/main.tf

# ─────────────────────────────────────────────────────────────────────────

# Deploys a Cloud Run service connected to your Week 7 VPC.

# Uses terraform_remote_state to read VPC outputs from Week 7 state.

# ─────────────────────────────────────────────────────────────────────────


terraform {

  required_version = ">= 1.6"


  backend "gcs" {

    bucket = "cis410-asefa-tfstate"   # same bucket as Week 7

    prefix = "terraform/week8"                 # different prefix = separate state

  }


  required_providers {

    google = { source = "hashicorp/google", version = "~> 5.0" }

  }

}


provider "google" {

  project = var.project_id

  region  = var.region

}


# ── Read VPC outputs from Week 7 state ───────────────────────────────────

# Instead of hardcoding vpc_name and subnet_name, read them from the

# state file that Week 7 terraform apply wrote to GCS.

data "terraform_remote_state" "week7" {

  backend = "gcs"

  config = {

    bucket = "cis410-asefa-tfstate"   # same bucket

    prefix = "terraform/week7"                 # Week 7 prefix

  }

}


# ── Cloud Run service ────────────────────────────────────────────────────

resource "google_cloud_run_v2_service" "flask_app" {

  name     = "cis410-flask-app"

  location = var.region


  template {

    containers {

      image = var.container_image   # full Artifact Registry path from tfvars

      ports { container_port = 5000 }


      resources {

        limits = { cpu = "1", memory = "512Mi" }

      }

    }


    scaling {

      min_instance_count = 0   # scale to zero when idle — no cost

      max_instance_count = 3   # lab ceiling

    }


    # Connect Cloud Run to the VPC from Week 7

    vpc_access {

      network_interfaces {

        network    = data.terraform_remote_state.week7.outputs.vpc_name

        subnetwork = data.terraform_remote_state.week7.outputs.subnet_name

      }

      egress = "PRIVATE_RANGES_ONLY"

    }

  }

}


# ── Allow public internet access ─────────────────────────────────────────

# Without this IAM binding, Cloud Run rejects unauthenticated requests.

resource "google_cloud_run_v2_service_iam_member" "public_access" {

  name     = google_cloud_run_v2_service.flask_app.name

  location = var.region

  role     = "roles/run.invoker"

  member   = "allUsers"

}