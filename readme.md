# infrastructure-cicd

This repo is a bolerplate and seed for how to setup infrastructure as a code and a cd/cd pipeline in GCP using Terraform and Cloud build.

## Setup

Setup you variables

```bash
PROJECT_STG=blog-infra-staging-1
PROJECT_PROD=blog-infra-production-1
```

Create the 2 projects

```bash
gcloud projects create $PROJECT_STG --name="Staging"
gcloud projects create $PROJECT_PROD --name="Production"
```

Create the 2 buckets used for maintaining the terraform state

```bash
gcloud storage buckets create "gs://$PROJECT_STG-tfstate"
gcloud storage buckets create "gs://$PROJECT_PROD-tfstate"
```

Fork the repositories.

- [gabihodoroaga/infrastructure-cicd](https://github.com/gabihodoroaga/infrastructure-cicd.git)
- [gabihodoroaga/pubsub-to-bigquery](https://github.com/gabihodoroaga/pubsub-to-bigquery.git)

Path the `infrastructure-cicd` project in order to match you environment.

These are the files and properties that need to be updated:

- **environments/production/backend.tf** - update the bucket property to match your production bucket name
- **environments/production/main.tf** - update the project property to match you production project name
- **environments/staging/backend.tf** - update the bucket property to match your staging bucket name
- **environments/staging/main.tf** - update the project property to match you staging project name

Push you changes.

## License

This project is licensed under the terms of the MIT license.
