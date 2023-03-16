locals {
  env                   = "staging"
  project               = "blog-infra-staging-1"
  region                = "us-central1"
  branch                = "main"
}

module "pubsub_to_bq" {
  source                = "../../modules/pubsub-to-bq"
  project               = local.project
  region                = local.region
  env                   = local.env
  branch                = local.branch
}
