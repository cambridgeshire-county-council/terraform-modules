module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "cambs-insight-${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Application = "Cambs-Insight"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "cambs-insight-ec2-sg" {
  name        = "${var.environment}-cambs-insight-ec2-sg"
  description = "${var.environment} EC2 Security Group for Cambs Insight"
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
    Application = "Cambs-Insight"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}
resource "aws_security_group" "cambs-insight-lb-sg" {
  name = "${var.environment}-cambs-insight-lb-sg"
  description = "${var.environment} load balancer group for Cambs Insight"
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
    Application = "Cambs-Insight"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "cambs-insight-rds-sg" {
  name        = "${var.environment}-cambs-insight-rds-sg"
  description = "${var.environment} RDS Security Group for Cambs Insight"

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
    Application = "Cambs-Insight"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}
