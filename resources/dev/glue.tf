resource "aws_glue_catalog_database" "moon_transformed" {
  name = "test_moon_dev_transformed"
}

resource "aws_glue_catalog_table" "transformed_sent" {
  database_name = aws_glue_catalog_database.moon_transformed.name
  name          = "sent"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  partition_keys {
    name = "year"
    type = "string"
  }
  partition_keys {
    name = "month"
    type = "string"
  }
  partition_keys {
    name = "day"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${element(split(":", aws_s3_bucket.data_lake.arn), 5)}/sent/transformed"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.compression" = "SNAPPY"
      }
    }
    columns {
      name = "email"
      type = "string"
    }
    columns {
      name = "campaign_id"
      type = "string"
    }
  }
}