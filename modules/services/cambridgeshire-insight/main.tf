resource "aws_instance" "cambs-insight-website" {
  ami                    = "ami-f976839e" 
  instance_type          = var.instance_size
  vpc_security_group_ids = ["${var.ec2_sg_id}"]
  key_name               = aws_key_pair._.key_name
  subnet_id              = "${var.subnet_id1}"
  # user_data              = <<-EOF
  #                 #!/bin/bash
  #                 sudo su
  #                 yum update -y
  #                 yum -y install httpd
  #                 sudo yum remove httpd-tools -y
  #                 sudo yum install php56 -y
  #                 sudo yum install php56-pdo -y
  #                 sudo yum install php-pdo_mysql -y
  #                 sudo yum install mysql -y
  #                 echo "#!/bin/bash" | sudo tee /etc/profile.d/ci_setup.sh
  #                 echo "MYSQL_ENDPOINT=${aws_db_instance.cambs-insight-database.address}" | sudo tee -a /etc/profile.d/ci_setup.sh
  #                 echo "MYSQL_USER=${var.db_user}" | sudo tee -a /etc/profile.d/ci_setup.sh
  #                 echo "MYSQL_PASSWORD=${random_password.db_password.result}" | sudo tee -a /etc/profile.d/ci_setup.sh
  #                 echo "MYSQL_DBNAME=${var.db_name}" | sudo tee -a /etc/profile.d/ci_setup.sh
  #                 chmod +x /etc/profile.d/ci_setup.sh
  #                 chown -R apache:apache /var/www/html
  #                 service httpd start
  #                 EOF
  iam_instance_profile   = aws_iam_instance_profile.cambs_insight_profile.name
  tags = {
    "Name" = "${var.server_name}",
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

resource "aws_lb" "Cambs-Insight-lb" {
  subnets = ["${var.subnet_id1}","${var.subnet_id2}"]
  security_groups = ["${var.lb_sg_id}"]
  tags = {
    "Application" = "Cambs-Insight"
  }
}

resource "aws_lb_target_group" "Cambs-Insight-http-tg" {
  port = 80
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"
  tags = {
    "Application" = "Cambs-Insight"
  }
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
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

resource "aws_iam_policy" "cambs_insight_iam_policy" {
  path        = "/"
  description = "Cambridgeshire Insight policy"
  policy = file("${path.module}/cambs_insight_iam_policy.json")
}

resource "aws_iam_role" "cambs_insight_iam_role" {
  assume_role_policy = file("${path.module}/cambs_insight_role_policy.json")
  tags = {
    "Application" = "Cambs-Insight"
  }
}

resource "aws_iam_instance_profile" "cambs_insight_profile" {
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