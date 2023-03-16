terraform {
  backend "gcs" {
    bucket = "blog-infra-production-1-tfstate"
    prefix = "env/production"
  }
}
