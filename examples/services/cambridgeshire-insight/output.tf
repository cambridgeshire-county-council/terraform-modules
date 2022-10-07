output "private_key" {
  value     = module.cambridgeshire-insight.private_key
  sensitive = true
}
output "alb_dns_name" {
  value       = module.cambridgeshire-insight.alb_dns_name
  description = "The domain name of the load balancer"
}