output "private_sg_id" {
  value = module.vpc.private_sg_id
}

output "public_sg_id" {
  value = module.vpc.public_sg_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "bastion_ip" {
  value = module.vpc.bastion_ip
}
