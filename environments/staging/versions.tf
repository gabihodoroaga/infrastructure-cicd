terraform {
  required_version = "~> v1.3.4"
}

provider "google" {
  project = var.project
}
