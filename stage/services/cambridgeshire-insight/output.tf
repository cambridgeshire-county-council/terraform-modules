output "ec2_dns_name" {
  value = module.cambridgeshire-insight.ec2_dns_name
}

output "ec2_ip" {
  value = module.cambridgeshire-insight.ec2_ip
}

output "private_key" {
  value     = module.cambridgeshire-insight.private_key
  sensitive = true
}
