output "master_ips" {
  value = module.cluster.master_ips
}
output "worker_ips" {
  value = module.cluster.worker_ips
}
output "elb_dns" {
  value = module.cluster.elb_dns
}
output "bastion_ip" {
  value = data.terraform_remote_state.vpc.outputs.bastion_ip
}
