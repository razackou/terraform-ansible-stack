locals {
  vpc_id           = "vpc-bc2bfac1"
  subnet_id        = "subnet-889b18a9"
  ssh_user         = "ubuntu"
  key_name         = "myKeyPair"
  private_key_path = "myKeyPair.pem"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "lamp" {
  name   = "lamp_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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

resource "aws_instance" "lamp" {
  ami                         = "ami-084568db4383264d4"
  subnet_id                   = local.subnet_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.lamp.id]
  iam_instance_profile        = aws_iam_instance_profile.cw_agent_profile.name
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.lamp.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.lamp.public_ip}, --private-key ${local.private_key_path} -u ${local.ssh_user} lamp_provision.yaml"
  }
}

output "lamp_ip" {
  value = aws_instance.lamp.public_ip
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

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.lamp_dashboard.dashboard_name
}

