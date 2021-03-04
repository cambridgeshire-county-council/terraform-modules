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

variable "db_name" {
  type    = string
  default = "datacamb_datadb"
}
variable "db_user" {
  type    = string
  default = "root"
}
variable "db_password" {
  type    = string
  default = "WLhSpsY88Urw2KJh"
}


resource "aws_instance" "cambs-insight-website" {
  ami                    = "ami-489f8e2c" //ami-098828924dc89ea4a latest?
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.cambs-insight-ec2-sg.id]
  key_name               = aws_key_pair._.key_name
  user_data              = <<-EOF
                  #!/bin/bash
                  sudo su
                  yum -y install httpd
                  aws s3 cp s3://cambs-insight/data.cambridgeshireinsight.org.uk.zip .
	                aws s3 cp s3://cambs-insight/Dump20210223.sql .
	                mysql -h ${aws_db_instance.cambs-insight-database.address} -P 3306 -u ${var.db_user} -p"${var.db_password}" "${var.db_name}" < Dump20210223.sql\n
                  unzip ~/data.cambridgeshireinsight.org.uk.zip -d .
                  sed -i 's/DBNAME/${var.db_name}/g' data.cambridgeshireinsight.org.uk/sites/default/settings.php
                  sed -i 's/DBUSER/${var.db_user}/g' data.cambridgeshireinsight.org.uk/sites/default/settings.php
                  sed -i 's/DBPASSWORD/${var.db_password}/g' data.cambridgeshireinsight.org.uk/sites/default/settings.php
                  sed -i 's/localhost/${aws_db_instance.cambs-insight-database.address}/g' data.cambridgeshireinsight.org.uk/sites/default/settings.php
                  IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
                  sed -i \"s/data.cambridgeshireinsight.org.uk/$IP/g\" data.cambridgeshireinsight.org.uk/sites/default/settings.php
                  sed -i \"s/'port' => ''/'port' => '3306'/g\" data.cambridgeshireinsight.org.uk/sites/default/settings.php
                  sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php.ini
                  sed -i '/<Directory \"\/var\/www\/html\">/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf
                  mv data.cambridgeshireinsight.org.uk/* /var/www/html/
                  mv data.cambridgeshireinsight.org.uk/.htaccess /var/www/html/
                  sudo systemctl enable httpd
                  sudo systemctl start httpd
                  EOF
  iam_instance_profile   = aws_iam_instance_profile.cambs_insight_profile.name
}

resource "aws_db_instance" "cambs-insight-database" {
  vpc_security_group_ids = [aws_security_group.cambs-insight-rds-sg.id]
  allocated_storage      = 5
  engine                 = "mysql"
  instance_class         = "db.t2.micro"
  username               = var.db_user
  password               = var.db_password
  skip_final_snapshot    = true
}

resource "aws_iam_policy" "cambs_insight_iam_policy" {
  name        = "cambs_insight_iam_policy"
  path        = "/"
  description = "Cambridgeshire Insight policy"

  policy = file("cambs_insight_iam_policy.json")
}

resource "aws_iam_role" "cambs_insight_iam_role" {
  name               = "cambs_insight_iam_role"
  assume_role_policy = file("cambs_insight_role_policy.json")
}

resource "aws_iam_instance_profile" "cambs_insight_profile" {
  name = "cambs_insight_profile"
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
