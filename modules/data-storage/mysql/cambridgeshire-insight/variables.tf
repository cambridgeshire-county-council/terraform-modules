variable "vpc_remote_state_key" {
    description = "The Terraform state describing VPC and security groups"
    type = string
}

variable "db_user" {
    description = "The username for the MySQL database"
}

variable "db_password" {
    description = "The password for the MySQL database"
}

variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
}