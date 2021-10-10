module "pipeline" {
  source               = "../modules/esp-events-pipeline"
  aws_region           = var.aws_region
  app_environment      = var.app_environment
  app_name             = var.app_name
  raw_shard_count      = var.raw_shard_count
  data_lake_bucket_arn = aws_s3_bucket.data_lake.arn
  event_type_name      = "sent"
}