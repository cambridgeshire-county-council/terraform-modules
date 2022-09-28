output "ec2_sg_id" {
  value       = aws_security_group.cambs-insight-ec2-sg.id
  description = "The id of the EC2 security group"
}

output "lb_sg_id" {
  value       = aws_security_group.cambs-insight-lb-sg.id
  description = "The id of the Load Balancer security group"
}

output "rds_sg_id" {
  value       = aws_security_group.cambs-insight-rds-sg.id
  description = "The id of the RDS security group"
}