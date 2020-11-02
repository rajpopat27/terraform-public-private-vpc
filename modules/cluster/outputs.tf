output "master_ips" {
  value = aws_instance.master.*.private_ip
}
output "worker_ips" {
  value = aws_instance.worker.*.private_ip
}
output "elb_dns" {
  value = aws_elb.public_lb.dns_name
}
