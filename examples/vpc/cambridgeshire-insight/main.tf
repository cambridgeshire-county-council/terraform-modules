provider "aws" {
  region = "eu-west-2"
}

module "cambridgeshire-insight-vpc" {
  source = "../../../modules/vpc/cambridgeshire-insight"
  environment = "staging"
}

