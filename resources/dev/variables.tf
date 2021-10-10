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