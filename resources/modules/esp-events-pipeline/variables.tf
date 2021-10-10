variable "app_name" {
  description = "The name of this app"
  type        = string
}

variable "app_environment" {
  description = "The deployment environment"
  type        = string
}

variable "aws_region" {
  description = "The region of the deployment in AWS"
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


variable "event_type_name" {
  description = "The name of the event we want to observe"
  type        = string
}