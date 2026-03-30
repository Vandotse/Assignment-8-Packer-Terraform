resource "aws_security_group" "bastion" {
  name   = "bastion-sg"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "bastion_ssh_in" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = [var.my_ip]
}

resource "aws_security_group_rule" "bastion_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "private" {
  name   = "private-sg"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "private_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private.id
  source_security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "private_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.private.id
  cidr_blocks       = ["0.0.0.0/0"]
}