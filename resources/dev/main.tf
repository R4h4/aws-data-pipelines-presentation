module "sent_events" {
  source               = "../modules/pipeline"
  app_environment      = var.app_environment
  app_name             = var.app_name
  raw_shard_count      = var.raw_shard_count
  data_lake_bucket_arn = aws_s3_bucket.data_lake.arn
  event_type_name      = "sent"
  database_name        = aws_glue_catalog_database.moon_transformed.name
  table_name           = aws_glue_catalog_table.transformed_sent.name
}