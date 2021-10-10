# Role for Firehose to pull events from the transformed stream
resource "aws_iam_role" "firehose_pull_kinesis" {
  name = "${var.app_name}-${var.app_environment}-firehose-pull-transformed-stream-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "pull_from_kinesis" {
  statement {
    effect = "Allow"
    actions = [
      "kinesis:*"
    ]
    resources = [aws_kinesis_stream.transformed.arn, "${aws_kinesis_stream.transformed.arn}/*"]
  }
}

resource "aws_iam_role_policy" "pull_kinesis" {
  policy = data.aws_iam_policy_document.pull_from_kinesis.json
  role   = aws_iam_role.firehose_pull_kinesis.id
}

# Role for Firehose to put data into s3 data-lake
resource "aws_iam_role" "firehose_put_data_lake_role" {
  name = "${var.app_name}-${var.app_environment}-firehose-transformed-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "put_s3_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      var.data_lake_bucket_arn,
      "${var.data_lake_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "firehose_put_datalake" {
  policy = data.aws_iam_policy_document.put_s3_policy.json
  role = aws_iam_role.firehose_put_data_lake_role.id
}

resource "aws_iam_role" "analytics_stream_put_data_lake_role" {
  name = "${var.app_name}-${var.app_environment}-analytics-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "kinesisanalytics.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "put_to_firehose" {
  statement {
    effect = "Allow"
    actions = [
      "firehose:*"
    ]
    resources = [aws_kinesis_firehose_delivery_stream.transformed_s3_stream.arn, "${aws_kinesis_firehose_delivery_stream.transformed_s3_stream.arn}/*"]
  }
}

data "aws_iam_policy_document" "write_to_cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "logs:*"
    ]
    resources = [aws_cloudwatch_log_group.frequency_analyzer.arn, "${aws_cloudwatch_log_group.frequency_analyzer.arn}/*"]
  }
}

resource "aws_iam_role_policy" "write_to_cloudwatch" {
  policy = data.aws_iam_policy_document.write_to_cloudwatch.json
  role = aws_iam_role.analytics_stream_put_data_lake_role.id
}

resource "aws_iam_role_policy" "put_to_firehose" {
  policy = data.aws_iam_policy_document.put_to_firehose.json
  role = aws_iam_role.analytics_stream_put_data_lake_role.id
}

resource "aws_iam_role_policy" "analytics_pull_kinesis" {
  policy = data.aws_iam_policy_document.pull_from_kinesis.json
  role = aws_iam_role.analytics_stream_put_data_lake_role.id
}
