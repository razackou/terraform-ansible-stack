output "lamp_ip" {
  value = aws_instance.lamp.public_ip
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.lamp_dashboard.dashboard_name
}
