variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "my_ip" {
  description = "Your IP for SSH access"
}

variable "key_name" {
  description = "SSH key name"
}

variable "ubuntu_ami_id" {
  description = "Ubuntu AMI"
}

variable "amazon_linux_ami_id" {
  description = "Amazon Linux AMI"
}