output "alb_dns_name" {
  value       = aws_lb.Cambs-Insight-lb.dns_name
  description = "The domain name of the load balancer"
}
output "private_key" {
  value = tls_private_key._.private_key_pem
  sensitive = true
}
output "ec2_ip" {
  value = aws_instance.cambs-insight-website.public_ip
}