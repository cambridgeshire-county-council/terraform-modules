variable "server_name" {
    description = "The name of the server in AWS"
    type = string
    default = "Cambridgeshire Insight"
}

variable "vpc_remote_state_key" {
    description = "The Terraform state describing VPC and security groups"
    type = string
}

variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
}

variable "instance_size" {
  description = "The AWS instance type"
  type = string
  default = "t2.medium"
}

variable "ec2_sg_id" {
  type = string
  description = "The id of the EC2 security group"
}

variable "lb_sg_id" {
  type = string
  description = "The id of the Load Balancer security group"
}

variable "vpc_id" {
  type = string
  description = "The id of the VPC"
}

variable "subnet_id1" {
  type = string
  description = "The id of the first subnet"
}

variable "subnet_id2" {
  type = string
  description = "The id of the second subnet"
}


