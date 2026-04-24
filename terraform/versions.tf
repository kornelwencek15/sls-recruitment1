terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Bucket name is passed at init time:
  #   terraform init -backend-config="bucket=YOUR_PROJECT_ID-terraform-state"
  backend "gcs" {
    prefix = "devops-test/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

