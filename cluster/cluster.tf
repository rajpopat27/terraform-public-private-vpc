data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
  workspace = "default"
}
module "cluster" {
  source            = "../modules/cluster"
  cluster_name      = terraform.workspace
  private_sg_id     = data.terraform_remote_state.vpc.outputs.private_sg_id
  private_subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_id
  public_sg_id      = data.terraform_remote_state.vpc.outputs.public_sg_id
  public_subnet_id  = data.terraform_remote_state.vpc.outputs.public_subnet_id
}

resource "aws_instance" "nfsServer" {
  count         = var.nfs ? 1 : 0
  ami           = var.nfs_ami
  instance_type = "t2.micro"
  tags          = merge(map("dns", var.cluster_name), var.tags)
}
