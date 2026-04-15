variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "flight-price-analytics"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-east1"
}

variable "bq_dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
  default     = "flight-prices"
}

variable "gcs_bucket_name" {
  description = "GCS bucket for raw data backups"
  type        = string
  default     = "flight-prices-bronze-gcs"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  type        = string
  default     = "STANDARD"
}

variable "enable_audit" {
  description = "Enable audit logging for GCS and BigQuery resources"
  type        = bool
  default     = false
}