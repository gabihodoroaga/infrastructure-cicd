resource "google_pubsub_topic" "demo_events" {
  name = "demo-events"
  project = var.project
}

resource "google_pubsub_subscription" "demo_events" {
  name  = "demo-events-sub"
  topic = google_pubsub_topic.demo_events.name
}

resource "google_bigquery_dataset" "demo_bq_dataset" {
  dataset_id    = "demo_bq_dataset"
  friendly_name = "demo_bq_dataset"
  location      = "US"
}

resource "google_bigquery_table" "demo_events" {
  dataset_id    = google_bigquery_dataset.demo_bq_dataset.dataset_id
  table_id      = "demo_events"
  schema        = file("${path.module}/resources/demo-events_schema.json")
}

resource "google_cloudbuild_trigger" "pubsub_to_bq" {
  name            = "pubsub-to-bq-${var.env}"
  description     = "Deploy pubsub-to-bq service on ${var.project}"
  project         = var.project
  github {
    owner = "gabihodoroaga"
    name  = "pubsub-to-bigquery"
    push {
      branch = "^${var.branch}$"
    }
  }

  filename = "cloudbuild-${var.env}.yaml"

  substitutions = {
    _GIN_MODE = var.env == "production" ? "release" : "debug"
    _LOG_LEVEL = var.env == "production" ? "info" : "debug"
    _TRACE_SAMPLE = var.env == "production" ? "0.001" : ""
    _SERVICE_NAME = "pubsub-to-bq"
    _PROJECT = var.project
    _REGION = var.region
    _PUBSUB_PROJECT = var.project
    _PUBSUB_TOPIC = google_pubsub_topic.demo_events.name
    _PUBSUB_SUBSCRIPTION = google_pubsub_subscription.demo_events.name
    _BIGQUERY_PROJECT = var.project
    _BIGQUERY_DATASET = google_bigquery_dataset.demo_bq_dataset.dataset_id
    _BIGQUERY_TABLE = google_bigquery_table.demo_events.table_id
  }

  approval_config {
    approval_required = var.env == "production" ? true : false
  }
}
