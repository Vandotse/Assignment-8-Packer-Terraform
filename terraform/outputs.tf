output "controller_ip" {
  value = aws_instance.controller.public_ip
}

output "private_ips" {
  value = concat(
    aws_instance.ubuntu[*].private_ip,
    aws_instance.amazon[*].private_ip
  )
}