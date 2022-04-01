terraform {
  backend "s3" {
    bucket = "${var.tfstate-bucket}"
    key    = "cambs-insight-${var.environment}/cambs-insight.tfstate"
    region = "eu-west-2"
  }
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

variable "db_name" {
  type    = string
  default = "datacamb_datadb"
}
variable "db_user" {
  type    = string
  default = "root"
}
variable "environment" {
  type    = string
  default = "dev"
}
variable "tfstate-bucket" {
  type    = string
  default = "ccc-terraform-states"
}
variable "vpc-id" {
  type    = string
  default = "vpc-59d58c31"
}
variable "subnet1-id" {
  type    = string
  default = "subnet-c5e28dbf"
}
variable "subnet2-id" {
  type    = string
  default = "subnet-ae8b36e2"
}



resource random_password "db_password" {
  length = 16
  special = false
}


resource "aws_instance" "cambs-insight-website" {
  ami                    = "ami-03e88be9ecff64781" 
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.cambs-insight-ec2-sg.id]
  key_name               = aws_key_pair._.key_name
  user_data              = <<-EOF
                  #!/bin/bash
                  sudo su
                  yum update -y
                  yum -y install httpd
                  sudo yum remove httpd-tools -y
                  sudo yum install php56 -y
                  sudo yum install php56-pdo -y
                  sudo yum install php-pdo_mysql -y
                  sudo yum install mysql -y
                  echo "#!/bin/bash" | sudo tee /etc/profile.d/ci_setup.sh
                  echo "MYSQL_ENDPOINT=${aws_db_instance.cambs-insight-database.address}" | sudo tee -a /etc/profile.d/ci_setup.sh
                  echo "MYSQL_USER=${var.db_user}" | sudo tee -a /etc/profile.d/ci_setup.sh
                  echo "MYSQL_PASSWORD=${random_password.db_password.result}" | sudo tee -a /etc/profile.d/ci_setup.sh
                  echo "MYSQL_DBNAME=${var.db_name}" | sudo tee -a /etc/profile.d/ci_setup.sh
                  chmod +x /etc/profile.d/ci_setup.sh
                  chown -R apache:apache /var/www/html
                  service httpd start
                  EOF
  iam_instance_profile   = aws_iam_instance_profile.cambs_insight_profile.name
  tags = {
    "Name" = "Cambs-Insight",
    "Application" = "Cambs-Insight"
  }
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 40
  }
  lifecycle {
   ignore_changes = [user_data]
  }
}

resource "aws_db_instance" "cambs-insight-database" {
  vpc_security_group_ids = [aws_security_group.cambs-insight-rds-sg.id]
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = var.db_user
  password               = random_password.db_password.result
  skip_final_snapshot    = true
  tags = {
    "Application" = "Cambs-Insight"
  }
  lifecycle {
   ignore_changes = [password]
  }
}

resource "aws_iam_policy" "cambs_insight_iam_policy" {
  # name        = "cambs_insight_iam_policy"
  path        = "/"
  description = "Cambridgeshire Insight policy"
  policy = file("cambs_insight_iam_policy.json")
}

resource "aws_iam_role" "cambs_insight_iam_role" {
  # name               = "cambs_insight_iam_role"
  assume_role_policy = file("cambs_insight_role_policy.json")
  tags = {
    "Application" = "Cambs-Insight"
  }
}

resource "aws_iam_instance_profile" "cambs_insight_profile" {
  # name = "cambs_insight_profile"
  role = aws_iam_role.cambs_insight_iam_role.name
}

resource "aws_iam_role_policy_attachment" "assign-policy-to-role-attach" {
  role       = aws_iam_role.cambs_insight_iam_role.name
  policy_arn = aws_iam_policy.cambs_insight_iam_policy.arn
  depends_on = [aws_iam_policy.cambs_insight_iam_policy]
}

resource "tls_private_key" "_" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "_" {
  public_key = tls_private_key._.public_key_openssh
  tags = {
    "Application" = "Cambs-Insight"
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

resource "aws_lb" "Cambs-Insight-lb" {
  # name = "Cambs-Insight"
  subnets            = ["${var.subnet1-id}", "${var.subnet2-id}"]
  security_groups = [ aws_security_group.cambs-insight-lb-sg.id ]
  tags = {
    "Application" = "Cambs-Insight"
  }
}

resource "aws_lb_target_group" "Cambs-Insight-http-tg" {
  # name = "Cambs-Insight-http-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = "${var.vpc-id}"
  tags = {
    "Application" = "Cambs-Insight"
  }
}

resource "aws_lb_target_group_attachment" "cambs-insight-tg-attachment" {
  target_group_arn = aws_lb_target_group.Cambs-Insight-http-tg.arn
  target_id        = aws_instance.cambs-insight-website.id
  port             = 80
}

resource "aws_lb_listener" "Cambs-Insight-lb-listener" {
  load_balancer_arn = aws_lb.Cambs-Insight-lb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.Cambs-Insight-http-tg.arn
  }
}


output "private_key" {
  value = tls_private_key._.private_key_pem
  sensitive = true
}
output "ec2_ip" {
  value = aws_instance.cambs-insight-website.public_ip
}
output "mysql_endpoint" {
  value = aws_db_instance.cambs-insight-database.endpoint
}
output "mysql_password" {
  value = random_password.db_password.result
  sensitive = true
}
