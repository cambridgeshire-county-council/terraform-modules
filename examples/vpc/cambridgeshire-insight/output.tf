output "ec2_sg_id" {
  value       = module.cambridgeshire-insight-vpc.ec2_sg_id
  description = "The id of the EC2 security group"
}

output "lb_sg_id" {
  value       = module.cambridgeshire-insight-vpc.lb_sg_id
  description = "The id of the Load Balancer security group"
}

output "rds_sg_id" {
  value       = module.cambridgeshire-insight-vpc.rds_sg_id
  description = "The id of the RDS security group"
}