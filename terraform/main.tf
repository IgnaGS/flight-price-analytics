terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "bigquery" {
  service            = "bigquery.googleapis.com"
  disable_on_destroy = false
}

resource "google_bigquery_dataset" "bq-dataset" {
  dataset_id = var.bq_dataset_id
  location   = var.region

  depends_on = [google_project_service.bigquery]
}

resource "google_bigquery_table" "stg_flight_data" {
  dataset_id = google_bigquery_dataset.bq-dataset.dataset_id
  table_id   = "stg_flight_data"

  time_partitioning {
    type  = "DAY"
    field = "departure_time"
  }

  clustering = ["source_city", "destination_city", "airline"]

  schema = jsonencode([
    { "name" : "airline", "type" : "STRING" },
    { "name" : "flight", "type" : "STRING" },
    { "name" : "source_city", "type" : "STRING" },
    { "name" : "departure_time", "type" : "TIMESTAMP" },
    { "name" : "stops", "type" : "STRING" },
    { "name" : "arrival_time", "type" : "TIMESTAMP" },
    { "name" : "destination_city", "type" : "STRING" },
    { "name" : "class", "type" : "STRING" },
    { "name" : "duration", "type" : "FLOAT" },
    { "name" : "days_left", "type" : "INTEGER" },
    { "name" : "price", "type" : "INTEGER" }
  ])
}

resource "google_bigquery_table" "fct_flight_prices" {
  dataset_id = google_bigquery_dataset.bq-dataset.dataset_id
  table_id   = "fct_flight_prices"

  time_partitioning {
    type  = "DAY"
    field = "departure_date"
  }

  clustering = ["source_city", "destination_city", "airline"]

  schema = jsonencode([
    { "name" : "departure_date", "type" : "DATE" },
    { "name" : "source_city", "type" : "STRING" },
    { "name" : "destination_city", "type" : "STRING" },
    { "name" : "airline", "type" : "STRING" },
    { "name" : "avg_price", "type" : "FLOAT" },
    { "name" : "min_price", "type" : "INTEGER" },
    { "name" : "max_price", "type" : "INTEGER" }
  ])
}

resource "google_storage_bucket" "bronze-gcs" {
  name          = var.gcs_bucket_name
  location      = var.region
  force_destroy = true
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }

  dynamic "logging" {
    for_each = var.enable_audit ? [1] : []
    content {
      log_bucket = google_storage_bucket.log-bucket.name
    }
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket" "log-bucket" {
  name          = "${var.gcs_bucket_name}-logs"
  location      = var.region
  force_destroy = true
}