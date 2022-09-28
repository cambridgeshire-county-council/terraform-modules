terraform {
  # backend "s3" {
  #   bucket = "${var.tfstate-bucket}"
  #   key    = "cambs-insight-${var.environment}/cambs-insight.tfstate"
  #   region = "eu-west-2"
  # }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

variable "environment" {
  type    = string
  default = "dev"
}
variable "tfstate-bucket" {
  type    = string
  default = "ccc-terraform-states"
}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}



resource random_password "db_password" {
  length = 16
  special = false
}













