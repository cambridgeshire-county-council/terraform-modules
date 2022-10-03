variable "vpc_remote_state_key" {
    description = "The Terraform state describing VPC and security groups"
    type = string
}

variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
}