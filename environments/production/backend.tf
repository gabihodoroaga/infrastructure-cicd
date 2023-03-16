terraform {
  backend "gcs" {
    bucket = "blog-infra-production-1-tfs"
    prefix = "env/production"
  }
}
