terraform {
  backend "s3" {
    key = "stage/services/application-server/terraform.tfstate"
  }
}


provider "aws" {
  region = "eu-west-2"
}

module "cambridgeshire-insight" {
  source = "../../../modules/services/cambridgeshire-insight"

  vpc_remote_state_key = "stage/vpc/terraform.tfstate"
  environment = "staging"
  instance_size = "t2.micro"
}