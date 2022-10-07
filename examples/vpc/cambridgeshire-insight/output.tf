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
output "vpc_id" {
  value       = module.cambridgeshire-insight-vpc.vpc_id
  description = "The id of the VPC"
}

output "subnet_id1" {
  value = module.cambridgeshire-insight-vpc.subnet_id1
  description = "First subnet ids"  
}

output "subnet_id2" {
  value = module.cambridgeshire-insight-vpc.subnet_id2
  description = "Second subnet ids"  
}
