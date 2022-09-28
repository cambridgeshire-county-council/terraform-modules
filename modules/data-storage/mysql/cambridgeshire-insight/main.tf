data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "ccc-terraform-state"
    key    = var.vpc_remote_state_key
    region = "eu-west-2"
  }
}

resource "aws_db_instance" "cambs-insight-database" {
  vpc_security_group_ids = ["${data.terraform_remote_state.vpc.outputs.rds_sg_id}"]
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = var.db_user
  password               = var.db_password
  skip_final_snapshot    = true
  tags = {
    "Application" = "Cambs-Insight"
  }
  lifecycle {
   ignore_changes = [password]
  }
}
