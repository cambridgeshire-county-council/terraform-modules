terraform {
    backend "s3" {
        key = "stage/data-storage/mysql/cambridgeshire-insight/terraform.tfstate"
    }
}

module "cambridgeshire-insight" {
  source = "../../../../modules/data-storage/mysql/cambridgeshire-insight"

  vpc_remote_state_key = "stage/vpc/terraform.tfstate"
  db_user = "admin"
  db_password = data.aws_secretsmanager_secret_version.db_password.secret_string
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "mysql-cambs-insight-password-stage"
}