output "dataset_id" {
  value = google_bigquery_dataset.bq-dataset.dataset_id
}

output "bucket_name" {
  value = google_storage_bucket.bronze-gcs.name
}