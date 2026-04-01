variable "region" {
  default = "us-east-1"
}

variable "my_ip" {
  description = "138.202.26.242/32"
  type        = string
}

variable "public_key_path" {
  default = "/Users/evanhaba/.ssh/aws-assignment-key.pub"
}

variable "private_key_path" {
  default = "/Users/evanhaba/.ssh/aws-assignment-key"
}

variable "ami_id" {
  description = "ami-034f715cd27f63d11"
  type        = string
}

resource "aws_key_pair" "assignment" {
  key_name   = "aws-assignment-key"
  public_key = file(var.public_key_path)
}