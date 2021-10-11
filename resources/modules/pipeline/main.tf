resource "aws_kinesis_stream" "transformed" {
  name        = "${var.app_name}-${var.app_environment}-${var.event_type_name}-transformed"
  shard_count = var.raw_shard_count
}

resource "aws_kinesis_firehose_delivery_stream" "transformed_s3_stream" {
  destination = "extended_s3"
  name        = "${var.app_name}-${var.app_environment}-${var.event_type_name}-s3-transformed-stream"

  extended_s3_configuration {
    bucket_arn      = var.data_lake_bucket_arn
    role_arn        = aws_iam_role.transformed_firehose_role.arn
    buffer_interval = 60
    buffer_size     = 64

    prefix              = "${var.event_type_name}/transformed/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "errors/${var.event_type_name}/transformed/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/!{firehose:random-string}/"

    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          open_x_json_ser_de {}
        }
      }
      output_format_configuration {
        serializer {
          parquet_ser_de {
            compression = "SNAPPY"
          }
        }
      }
      schema_configuration {
        database_name = var.database_name
        role_arn      = aws_iam_role.transformed_firehose_role.arn
        table_name    = var.table_name
      }
    }
  }

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.transformed.arn
    role_arn           = aws_iam_role.transformed_firehose_role.arn
  }
}