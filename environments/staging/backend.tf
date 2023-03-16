terraform {
  backend "gcs" {
    bucket = "blog-infra-staging-1-tfstate"
    prefix = "env/staging"
  }
}
