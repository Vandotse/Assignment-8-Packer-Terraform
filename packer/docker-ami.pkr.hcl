packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "public_key_path" {
  type    = string
  default = "/Users/evanhaba/.ssh/aws-assignment-key.pub"
}

source "amazon-ebs" "al2-docker" {
  region        = var.region
  instance_type = "t2.micro"
  ssh_username  = "ec2-user"
  ami_name      = "evan-docker-ami-{{timestamp}}"

  # easiest beginner option: paste a valid Amazon Linux 2 AMI ID here
  source_ami = "ami-0c3389a4fa5bddaad"
}

build {
  sources = ["source.amazon-ebs.al2-docker"]

  provisioner "shell" {
    script = "scripts/setup.sh"
  }

  provisioner "file" {
    source      = var.public_key_path
    destination = "/tmp/aws-assignment-key.pub"
  }

  provisioner "shell" {
    inline = [
      "mkdir -p /home/ec2-user/.ssh",
      "cat /tmp/aws-assignment-key.pub >> /home/ec2-user/.ssh/authorized_keys",
      "chown -R ec2-user:ec2-user /home/ec2-user/.ssh",
      "chmod 700 /home/ec2-user/.ssh",
      "chmod 600 /home/ec2-user/.ssh/authorized_keys"
    ]
  }
}