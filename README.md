# AWS AMI + Terraform Infrastructure (Bastion + Private EC2)

## Overview
This project builds a custom AWS environment using **Packer** and **Terraform**.

- Packer creates a custom AMI with:
  - Amazon Linux 2023
  - Docker installed
  - SSH access using my public key

- Terraform provisions:
  - VPC with public + private subnets
  - 1 bastion host (public subnet)
  - 6 EC2 instances (private subnets)
  - Security groups for controlled SSH access

The goal is to securely access private instances through a bastion host.


ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws-assignment-key

## Step 1: Build Custom AMI (Packer)
cd packer
packer init .
packer validate .
packer build .

After build finishes, copy the AMI ID.

## Step 2: Configure Terraform Variables

Create:

terraform/terraform.tfvars

Add:

ami_id = "ami-xxxxxxxxxxxxxxxxx"
my_ip  = "YOUR_IP/32"


## Step 3: Deploy Infrastructure
cd terraform
terraform init
terraform plan
terraform apply

How to Connect
1. SSH into Bastion
ssh -A -i ~/.ssh/aws-assignment-key ec2-user@<BASTION_PUBLIC_IP>
<img width="1470" height="956" alt="Screenshot 2026-03-30 at 1 56 35 PM" src="https://github.com/user-attachments/assets/69087d1f-55e0-41fa-9d84-8b85fc7700a9" />

2. SSH into Private Instance (from Bastion)
ssh ec2-user@<PRIVATE_IP>
<img width="1470" height="956" alt="Screenshot 2026-03-30 at 1 58 19 PM" src="https://github.com/user-attachments/assets/7238f48d-ab6a-47a2-ac22-e6fbddb1a29f" />

<img width="1470" height="956" alt="Screenshot 2026-03-30 at 1 58 32 PM" src="https://github.com/user-attachments/assets/0e48f9db-dfa7-41d8-b7d5-6928beb61298" />

