# Starting point stream
resource "aws_kinesis_stream" "transformed" {
  name        = "${var.app_name}-${var.app_environment}-transformed"
  shard_count = var.raw_shard_count
}

resource "aws_kinesis_firehose_delivery_stream" "transformed_s3_stream" {
  name        = "${var.app_name}-${var.app_environment}-${var.event_type_name}-s3-transformed-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_put_data_lake_role.arn
    bucket_arn = var.data_lake_bucket_arn
    buffer_interval = 60
    buffer_size = 1

    prefix              = "${var.event_type_name}/transformed/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "${var.event_type_name}/transformed/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/!{firehose:random-string}/"
  }

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.transformed.arn
    role_arn           = aws_iam_role.firehose_pull_kinesis.arn
  }
}

resource "aws_kinesis_firehose_delivery_stream" "aggregated_s3_stream" {
  name        = "${var.app_name}-${var.app_environment}-${var.event_type_name}-s3-aggregated-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_put_data_lake_role.arn
    bucket_arn = var.data_lake_bucket_arn
    buffer_interval = 60
    buffer_size = 1

    prefix              = "${var.event_type_name}/aggregated/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "${var.event_type_name}/aggregated/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/!{firehose:random-string}/"
  }
}

resource "aws_kinesisanalyticsv2_application" "event_frequency_analyzer" {
  name                   = "${var.app_name}-${var.app_environment}-${var.event_type_name}-frequency-analyzer"
  runtime_environment    = "SQL-1_0"
  service_execution_role = aws_iam_role.analytics_stream_put_data_lake_role.arn

  application_configuration {
    application_code_configuration {
      code_content {
        text_content = file("${path.module}/stream_aggregation.sql")
      }

      code_content_type = "PLAINTEXT"
    }

    sql_application_configuration {
      input {
        name_prefix = "prefix"

        input_parallelism {
          count = 3
        }

        input_schema {
          record_column {
            name     = "email"
            sql_type = "VARCHAR(80)"
            mapping  = "prefix__1"
          }

          record_column {
            name     = "campaign_id"
            sql_type = "VARCHAR(80)"
            mapping  = "prefix__1"
          }

          record_encoding = "UTF-8"

          record_format {
            record_format_type = "JSON"

            mapping_parameters {
              json_mapping_parameters {
                record_row_path = "$"
              }
            }
          }
        }

        kinesis_streams_input {
          resource_arn = aws_kinesis_stream.transformed.arn
        }
      }
      output {
        name = "OUTPUT_S3"

        destination_schema {
          record_format_type = "JSON"
        }

        kinesis_firehose_output {
          resource_arn = aws_kinesis_firehose_delivery_stream.aggregated_s3_stream.arn
        }
      }
    }
  }

  cloudwatch_logging_options {
    log_stream_arn = aws_cloudwatch_log_stream.analyzer.arn
  }
}
