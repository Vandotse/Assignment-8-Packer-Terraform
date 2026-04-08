# Assignment 11 — Terraform + Ansible (Multi-OS EC2)

## Overview

This assignment extends the previous Terraform infrastructure to:

Provision 7 EC2 instances
3 Ubuntu (private subnet)
3 Amazon Linux (private subnet)
1 Ansible Controller (public subnet)
Tag instances with OS type
Use Ansible to configure the 6 private instances:
Update/upgrade packages
Verify Docker version
Report disk usage

## Step 1 — Setup Variables

Create a terraform.tfvars file:

amazon_linux_ami_id = "ami-xxxx"
ubuntu_ami_id       = "ami-xxxx"
key_name            = "labsuser"
my_ip               = "YOUR_IP/32"
Notes:
Get your IP by searching "what is my IP"
Use /32 for security
AMIs are found in AWS EC2 → AMIs


## Step 2 — Deploy Infrastructure
terraform init
terraform fmt
terraform validate
terraform apply

<img width="1470" height="956" alt="Screenshot 2026-03-30 at 2 29 41 PM" src="https://github.com/user-attachments/assets/88c1ca37-2328-4bd1-8cdf-0edd7c3d28bc" />

## Step 3 — Get Outputs
terraform output -raw controller_ip
terraform output private_ips

Save these values.

## Step 4 — SSH into Ansible Controller
ssh -i ~/.ssh/labsuser.pem ec2-user@<controller_ip>


## Step 5 — Install Ansible

On the controller:

sudo dnf update -y
sudo dnf install -y ansible-core
ansible --version

<img width="1470" height="956" alt="Screenshot 2026-04-08 at 3 52 54 PM" src="https://github.com/user-attachments/assets/37f2e0b3-8640-4b4a-b895-5b0ccc4983ae" />


## Step 6 — Copy SSH Key to Controller

From your local machine:

scp -i ~/.ssh/labsuser.pem ~/.ssh/labsuser.pem ec2-user@<controller_ip>:/home/ec2-user/

Then on controller:

chmod 400 ~/labsuser.pem


## Step 7 — Copy Ansible Files
scp -r -i ~/.ssh/labsuser.pem ansible ec2-user@<controller_ip>:/home/ec2-user/


## Step 8 — Update Inventory

Edit ansible/inventory.ini with private IPs:

[ubuntu]
10.0.2.x ansible_user=ubuntu

[amazon]
10.0.2.x ansible_user=ec2-user

[all:children]
ubuntu
amazon


## Step 9 — Test Connectivity

From the controller:

cd ~/ansible
ansible all -i inventory.ini -m ping --private-key ~/labsuser.pem

Expected output:

pong


## Step 10 — Run Ansible Playbook
ansible-playbook -i inventory.ini playbook.yml --private-key ~/labsuser.pem

<img width="1470" height="956" alt="Screenshot 2026-04-08 at 4 02 06 PM" src="https://github.com/user-attachments/assets/845d817d-8185-4807-b257-8f776e2f70fd" />





