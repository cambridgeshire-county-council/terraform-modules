terraform {
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

resource "aws_instance" "cambs-insight-website" {
  ami                    = "ami-489f8e2c" //ami-098828924dc89ea4a latest?
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.cambs-insight-ec2-sg.id]
  key_name               = aws_key_pair._.key_name

}

# resource "aws_db_instance" "cambs-insight-database" {
#   vpc_security_group_ids = [aws_security_group.cambs-insight-rds-sg.id]
#   allocated_storage      = 5
#   engine                 = "mysql"
#   instance_class         = "db.t2.micro"
#   username               = "root"
#   password               = "WLhSpsY88Urw2KJh"
#   skip_final_snapshot    = true
# }

resource "tls_private_key" "_" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "_" {
  key_name   = "cambs-insight"
  public_key = tls_private_key._.public_key_openssh
}


resource "aws_security_group" "cambs-insight-ec2-sg" {
  name        = "cambs-insight-ec2-sg"
  description = "EC2 Security Group for Cambs Insight"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Telnet"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "cambs-insight-rds-sg" {
  name        = "cambs-insight-rds-sg"
  description = "RDS Security Group for Cambs Insight"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    description     = "MySQL"
    security_groups = [aws_security_group.cambs-insight-ec2-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "private_key" {
  value = tls_private_key._.private_key_pem
}
output "ec2_ip" {
  value = aws_instance.cambs-insight-website.public_ip
}
