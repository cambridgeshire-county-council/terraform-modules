terraform {
    backend "s3" {
        key = "stage/vpc/terraform.tfstate"
    }
}

resource "aws_security_group" "cambs-insight-ec2-sg" {
  # name        = "cambs-insight-ec2-sg"
  description = "EC2 Security Group for Cambs Insight"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Telnet"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Http"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Application" = "Cambs-Insight"
  }
}
resource "aws_security_group" "cambs-insight-lb-sg" {
  # name = "cambs-insight-lb-sg"
  description = "Load balancer group for Cambs Insight"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "HTTPS"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Application" = "Cambs-Insight"
  }
}

resource "aws_security_group" "cambs-insight-rds-sg" {
  # name        = "cambs-insight-rds-sg"
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
    tags = {
    "Application" = "Cambs-Insight"
  }
}