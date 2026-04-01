resource "aws_instance" "monitoring" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.monitoring.id]
  key_name               = aws_key_pair.assignment.key_name

  user_data = templatefile("${path.module}/templates/monitoring-userdata.sh", {
    private_ips        = aws_instance.private[*].private_ip
    bastion_ip         = aws_instance.bastion.private_ip
    dashboard_json_b64 = base64encode(file("${path.module}/files/grafana-dashboard.json"))
  })

  tags = {
    Name = "monitoring-prometheus-grafana"
  }
}
