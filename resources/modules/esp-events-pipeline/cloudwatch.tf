resource "aws_cloudwatch_log_group" "frequency_analyzer" {
  name = "${var.app_name}-${var.app_environment}-${var.event_type_name}-logs"
}

resource "aws_cloudwatch_log_stream" "analyzer" {
  log_group_name = aws_cloudwatch_log_group.frequency_analyzer.name
  name           = "${var.event_type_name}-frequenzy-analyzer"
}