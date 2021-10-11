variable "app_name" {
  description = "The name of this app"
  type        = string
}

variable "app_environment" {
  description = "The deployment environment"
  type        = string
}

variable "event_type_name" {
  description = "The name of the event we want to observe"
  type        = string
}

variable "raw_shard_count" {
  description = "The number of shards in the raw Kinesis Data Stream"
  type        = number
}

variable "data_lake_bucket_arn" {
  description = "The ARN of the data lake bucket"
  type        = string
}

variable "database_name" {
  description = "Data lake transformed datbase"
  type        = string
}

variable "table_name" {
  description = "Transoformed send events"
  type        = string
}