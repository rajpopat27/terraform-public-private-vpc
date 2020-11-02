output "private_sg_id" {
  value = aws_security_group.private_sg.id
}

output "public_sg_id" {
  value = aws_security_group.public_sg.id
}

output "private_subnet_id" {
  value = aws_subnet.private.*.id
}

output "public_subnet_id" {
  value = aws_subnet.public.*.id
}
