provider "aws" {
  region = "eu-west-2"
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../../vpc/cambridgeshire-insight/terraform.tfstate"
   }
}

module "cambridgeshire-insight" {
  source = "../../../modules/services/cambridgeshire-insight"

  vpc_remote_state_key = "stage/vpc/terraform.tfstate"
  environment = "staging"
  instance_size = "t2.micro"
  ec2_sg_id = "${data.terraform_remote_state.vpc.outputs.ec2_sg_id}"
  lb_sg_id = "${data.terraform_remote_state.vpc.outputs.lb_sg_id}"
  vpc_id = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  subnet_id1 = "${data.terraform_remote_state.vpc.outputs.subnet_id1}"
  subnet_id2 = "${data.terraform_remote_state.vpc.outputs.subnet_id2}"
  
}