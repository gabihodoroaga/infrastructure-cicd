# infrastructure-cicd

This repo is a boilerplate and seed for how to setup infrastructure as a code and a cd/cd pipeline in GCP using Terraform and Cloud build.

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
gcloud storage buckets create "gs://$PROJECT_STG-tfs" --project $PROJECT_STG
gcloud storage buckets create "gs://$PROJECT_PROD-tfs" --project $PROJECT_PROD
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

Login to your [GCP Console](https://console.cloud.google.com) and enable billing.
Check the official documentation https://cloud.google.com/billing/docs/how-to/modify-project if you have to.

Then go to Cloud Build, enable the api and connect the 2 repositories. You have to do it for both projects: production and staging.

Cloud Build -> Triggers -> Connect Repository

![connect-repo](resources/img/post-43-connect-repo.png)

Do not use the "repositories (2nd gen)" option because is still in preview and I don't know how it works.

If you did this process correctly you should find the 2 repositories in you "Manage repositories" like in the 
picture bellow

![manage-repo](resources/img/post-43-manage-repo.png)

Next we need to create the build trigger for infra for each of the projects. 

Staging, but first set you repo owner name

```
REPO_OWNER=[your_github_user]
```

```bash
gcloud beta builds triggers create github \
    --region=global \
    --repo-name=infrastructure-cicd \
    --repo-owner=$REPO_OWNER \
    --branch-pattern='^main$' \
    --build-config=cloudbuild-staging.yaml \
    --project $PROJECT_STG
```

and then production

```bash
gcloud beta builds triggers create github \
    --region=global \
    --repo-name=infrastructure-cicd \
    --repo-owner=$REPO_OWNER \
    --branch-pattern='^production$' \
    --build-config=cloudbuild-production.yaml \
    --require-approval \
    --project $PROJECT_PROD
```

You can update the trigger names and description from the GCP Console.

Before trigging an update to our repo we need to adjust the Cloud Build service account permissions.

For Staging:

```bash
PROJECT_NUMBER=$(gcloud projects list --filter="$PROJECT_STG" --format="value(PROJECT_NUMBER)")
CB_SERVICE_ACCOUNT="$PROJECT_NUMBER@cloudbuild.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_STG \
    --member="serviceAccount:$CB_SERVICE_ACCOUNT" \
    --condition=None \
    --role="roles/editor"

gcloud projects add-iam-policy-binding $PROJECT_STG \
    --member="serviceAccount:$CB_SERVICE_ACCOUNT" \
    --condition=None \
    --role="roles/iam.serviceAccountUser"

# if you need to deploy a cloud run service
gcloud projects add-iam-policy-binding $PROJECT_STG \
    --member="serviceAccount:$CB_SERVICE_ACCOUNT" \
    --condition=None \
    --role="roles/run.admin"
# if you need to create a service account
gcloud projects add-iam-policy-binding $PROJECT_STG \
    --member="serviceAccount:$CB_SERVICE_ACCOUNT" \
    --condition=None \
    --role="roles/iam.serviceAccountAdmin"
# if you need to create secrets
gcloud projects add-iam-policy-binding $PROJECT_STG \
    --member="serviceAccount:$CB_SERVICE_ACCOUNT" \
    --condition=None \
    --role="roles/secretmanager.admin"
# if you need to access secrets
gcloud projects add-iam-policy-binding $PROJECT_STG \
    --member="serviceAccount:$CB_SERVICE_ACCOUNT" \
    --condition=None \
    --role="roles/secretmanager.secretAccessor"
```

For Production:

```bash
PROJECT_NUMBER=$(gcloud projects list --filter="$PROJECT_PROD" --format="value(PROJECT_NUMBER)")
CB_SERVICE_ACCOUNT="$PROJECT_NUMBER@cloudbuild.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_PROD \
    --member="serviceAccount:$CB_SERVICE_ACCOUNT" \
    --condition=None \
    --role="roles/editor"

gcloud projects add-iam-policy-binding $PROJECT_PROD \
    --member="serviceAccount:$CB_SERVICE_ACCOUNT" \
    --condition=None \
    --role="roles/iam.serviceAccountUser"

# if you need to deploy a cloud run service
gcloud projects add-iam-policy-binding $PROJECT_PROD \
    --member="serviceAccount:$CB_SERVICE_ACCOUNT" \
    --condition=None \
    --role="roles/run.admin"
# if you need to create a service account
gcloud projects add-iam-policy-binding $PROJECT_PROD \
    --member="serviceAccount:$CB_SERVICE_ACCOUNT" \
    --condition=None \
    --role="roles/iam.serviceAccountAdmin"
# if you need to create secrets
gcloud projects add-iam-policy-binding $PROJECT_PROD \
    --member="serviceAccount:$CB_SERVICE_ACCOUNT" \
    --condition=None \
    --role="roles/secretmanager.admin"
# if you need to access secrets
gcloud projects add-iam-policy-binding $PROJECT_PROD \
    --member="serviceAccount:$CB_SERVICE_ACCOUNT" \
    --condition=None \
    --role="roles/secretmanager.secretAccessor"
```

Or, you can add the owner role if you are too lazy to run all these commands, but I do not recommend this.

Next let's update the infra project and push the changes to main and see what happens.

You should update the github repo owner for the pubsub-to-bq service anyway

**modules/pubsub-to-bq/main.tf** -> google_cloudbuild_trigger -> pubsub_to_bq -> github -> owner 

with your github username.

Push the changes to the main branch.

If everything works well you should see the all the staging resources created and also the Cloud Build trigger 
for the `pubsub-to-bq` service.


## License

This project is licensed under the terms of the MIT license.
