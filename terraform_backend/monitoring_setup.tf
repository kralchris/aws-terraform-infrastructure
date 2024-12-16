# VPC Flow Logs into CloudWatch
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "vpc-flow-logs"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_stream" "vpc_flow_logs_stream" {
  name           = "vpc-flow-logs-stream"
  log_group_name = aws_cloudwatch_log_group.vpc_flow_logs.name
}

resource "aws_flow_log" "vpc" {
  log_group_name   = aws_cloudwatch_log_group.vpc_flow_logs.name
  traffic_type     = "ALL"
  vpc_id           = aws_vpc.main.id
  iam_role_arn     = aws_iam_role.vpc_flow_logs_role.arn
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "vpc-flow-logs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name   = "vpc-flow-logs-policy"
  role   = aws_iam_role.vpc_flow_logs_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# CloudWatch EC2 Alerts and SNS Notification
resource "aws_sns_topic" "ec2_alerts" {
  name = "ec2-alerts-topic-internship-kristijan"
}

resource "aws_sns_topic_subscription" "email_subscription_kristijan" {
  topic_arn = aws_sns_topic.ec2_alerts.arn
  protocol  = "email"
  endpoint  = "kristijan.sarin@trustsoft.eu"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sns_topic_subscription" "email_subscription_adam" {
  topic_arn = aws_sns_topic.ec2_alerts.arn
  protocol  = "email"
  endpoint  = "adam.simo@trustsoft.com"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name                = "High-CPU-Utilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 80
  alarm_actions             = [aws_sns_topic.ec2_alerts.arn]
  dimensions = {
    InstanceId = aws_instance.webserver_1.id
  }
  insufficient_data_actions = []
}

# EC2 CloudWatch Agent Setup for Additional Metrics
resource "aws_ssm_document" "cloudwatch_agent_config" {
  name          = "CloudWatch-Agent-Config"
  document_type = "Command"

  content = <<EOF
  {
    "schemaVersion": "2.2",
    "description": "Install and configure the CloudWatch Agent.",
    "mainSteps": [
      {
        "action": "aws:runShellScript",
        "name": "InstallCloudWatchAgent",
        "inputs": {
          "runCommand": [
            "sudo yum install -y amazon-cloudwatch-agent",
            "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:CloudWatch-Agent-Config -s"
          ]
        }
      }
    ]
  }
  EOF
}

resource "aws_ssm_association" "cloudwatch_agent_run" {
  name = aws_ssm_document.cloudwatch_agent_config.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.webserver_1.id]
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  alarm_name                = "High-Memory-Utilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 2
  metric_name               = "mem_used_percent"
  namespace                 = "CWAgent"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 80
  alarm_actions             = [aws_sns_topic.ec2_alerts.arn]
  dimensions = {
    InstanceId = aws_instance.webserver_1.id
  }
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "disk_utilization" {
  alarm_name                = "High-Disk-Utilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 2
  metric_name               = "disk_used_percent"
  namespace                 = "CWAgent"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 80
  alarm_actions             = [aws_sns_topic.ec2_alerts.arn]
  dimensions = {
    InstanceId = aws_instance.webserver_1.id
  }
  insufficient_data_actions = []
}