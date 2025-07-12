# AWS Infrastructure with Terraform

This project provisions a complete AWS infrastructure using Terraform, including:
- A custom VPC with public and private subnets across 2 Availability Zones
- An EC2 instance in the public subnet
- An RDS MySQL database in the private subnets
- Internet Gateway, Route Tables, and Security Groups
- Fully automated IaC setup using Terraform

## Tech Stack
- Terraform
- AWS (VPC, EC2, RDS)
- HCL

## Setup Instructions

1. Clone the repo
2. Configure your AWS CLI (`aws configure`)
3. Run:
   ```bash
   terraform init
   terraform plan
   terraform apply
