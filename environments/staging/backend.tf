terraform {
  backend "gcs" {
    bucket = "blog-infra-staging-1-tfs"
    prefix = "env/staging"
  }
}
