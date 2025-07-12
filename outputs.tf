output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "rds_endpoint" {
  description = "The endpoint of the RDS database"
  value       = aws_db_instance.rds_instance.endpoint
  sensitive   = true
}


Outputs:

ec2_public_ip = "3.123.45.67"
rds_endpoint = (sensitive value)
