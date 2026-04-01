# AWS AMI + Terraform Infrastructure (Bastion + Private EC2)

## Overview
This project builds a custom AWS environment using **Packer** and **Terraform**, and extends it with **Prometheus and Grafana monitoring**.

- Packer creates a custom AMI with:
  - Amazon Linux 2023
  - Docker installed
  - SSH access using my public key
  - Node Exporter (for monitoring)

- Terraform provisions:
  - VPC with public + private subnets
  - 1 bastion host (public subnet)
  - 6 EC2 instances (private subnets)
  - 1 monitoring EC2 instance (private subnet)
  - Security groups for controlled SSH access

- Monitoring:
  - Prometheus collects metrics from all EC2 instances
  - Grafana visualizes CPU and memory usage

The goal is to securely access private instances through a bastion host.


ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws-assignment-key

## Step 1: Build Custom AMI (Packer)
cd packer
packer init .
packer validate .
packer build .
<img width="1470" height="956" alt="Screenshot 2026-04-01 at 1 36 19 PM" src="https://github.com/user-attachments/assets/2252c36e-1f03-4771-9818-c1b236de6680" />

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
<img width="1470" height="956" alt="Screenshot 2026-03-30 at 2 29 41 PM" src="https://github.com/user-attachments/assets/88c1ca37-2328-4bd1-8cdf-0edd7c3d28bc" />

How to Connect
1. SSH into Bastion
ssh -A -i ~/.ssh/aws-assignment-key ec2-user@<BASTION_PUBLIC_IP>
<img width="1470" height="956" alt="Screenshot 2026-03-30 at 1 56 35 PM" src="https://github.com/user-attachments/assets/69087d1f-55e0-41fa-9d84-8b85fc7700a9" />

2. SSH into Private Instance (from Bastion)
ssh ec2-user@<PRIVATE_IP>

<img width="1470" height="956" alt="Screenshot 2026-03-30 at 1 58 32 PM" src="https://github.com/user-attachments/assets/0e48f9db-dfa7-41d8-b7d5-6928beb61298" />

## Monitoring Setup

Grafana
Runs on monitoring EC2
Connected to Prometheus as a data source
Used to visualize metrics
Access Prometheus & Grafana

Since the monitoring server is in a private subnet, use SSH tunneling.



Grafana (port 3000)

From your local machine:

ssh -i ~/.ssh/aws-assignment-key -L 3000:<MONITORING_PRIVATE_IP>:3000 ec2-user@<BASTION_PUBLIC_IP>

Open:

http://localhost:3000

Grafana Dashboard (BONUS)

A dashboard was created showing:

CPU utilization per EC2 instance
Memory utilization per EC2 instance

<img width="1470" height="956" alt="Screenshot 2026-04-01 at 1 50 11 PM" src="https://github.com/user-attachments/assets/c0302200-6f6b-4e79-b613-c30154e92c20" />


Default login:

admin / admin


Prometheus

Runs on monitoring EC2
Scrapes metrics from all 6 private EC2 instances
Uses Node Exporter on port 9100

Prometheus (port 9090)
ssh -i ~/.ssh/aws-assignment-key -L 9090:<MONITORING_PRIVATE_IP>:9090 ec2-user@<BASTION_PUBLIC_IP>

Open:

http://localhost:9090

<img width="1470" height="956" alt="Screenshot 2026-04-01 at 1 50 32 PM" src="https://github.com/user-attachments/assets/d6b2e52d-b488-4231-b29c-23dc9909a720" />


