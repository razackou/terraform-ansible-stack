resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "ec2-cloudwatch-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "cw_agent_profile" {
  name = "cw-agent-profile"
  role = aws_iam_role.cloudwatch_agent_role.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "High-CPU-Usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "This metric monitors CPU usage"
  dimensions = {
    InstanceId = aws_instance.lamp.id
  }
  alarm_actions = [] # You can add SNS topic ARN here
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "High-Memory-Usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "This metric monitors memory usage"
  dimensions = {
    InstanceId = aws_instance.lamp.id
  }
  alarm_actions = []
}

resource "aws_cloudwatch_metric_alarm" "disk_high" {
  alarm_name          = "High-Disk-Usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "This metric monitors disk usage"
  dimensions = {
    InstanceId = aws_instance.lamp.id
    path       = "/"
    fstype     = "ext4"
  }
  alarm_actions = []
}

resource "aws_cloudwatch_dashboard" "lamp_dashboard" {
  dashboard_name = "LAMP-Monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.lamp.id]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "us-east-1",
          "title" : "CPU Utilization"
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 6,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["CWAgent", "mem_used_percent", "InstanceId", aws_instance.lamp.id]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "us-east-1",
          "title" : "Memory Usage"
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 12,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["CWAgent", "disk_used_percent", "InstanceId", aws_instance.lamp.id, "path", "/", "fstype", "ext4"]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "us-east-1",
          "title" : "Disk Usage"
        }
      }
    ]
  })
}
