resource "aws_s3_bucket" "data_lake" {
  bucket = "${var.app_name}-${var.app_environment}-data-lake"
  acl    = "private"
  force_destroy = true
}