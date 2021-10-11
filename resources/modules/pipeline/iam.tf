resource "aws_iam_role" "transformed_firehose_role" {
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

data "aws_iam_policy_document" "put_to_datalake" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [var.data_lake_bucket_arn, "${var.data_lake_bucket_arn}/*"]
  }
}

data "aws_iam_policy_document" "data_lake_get_glue" {
  statement {
    effect = "Allow"
    actions = [
      "glue:GetTable",
      "glue:GetTableVersion",
      "glue:GetTableVersions"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "firehose_pull_kinesis" {
  policy = data.aws_iam_policy_document.pull_from_kinesis.json
  role   = aws_iam_role.transformed_firehose_role.id
}

resource "aws_iam_role_policy" "put_to_datalake" {
  policy = data.aws_iam_policy_document.put_to_datalake.json
  role   = aws_iam_role.transformed_firehose_role.id
}

resource "aws_iam_role_policy" "glue_get_information" {
  policy = data.aws_iam_policy_document.data_lake_get_glue.json
  role   = aws_iam_role.transformed_firehose_role.id
}