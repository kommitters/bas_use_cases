
# Infrastructure Documentation

This document provides deployment instructions for the BAS automation system infrastructure on multiple cloud providers.

## Architecture Overview

The infrastructure deploys two instances:
- **Application Server**: Runs the BAS automation system
- **Database Server**: Dedicated PostgreSQL instance for data persistence

Both instances are configured with secure networking and automated provisioning scripts.

## Cloud Provider Support

Choose between Digital Ocean and AWS based on your requirements:
- **Digital Ocean**: Simpler setup, droplet-based infrastructure
- **AWS**: More configuration options, EC2-based infrastructure

## Using Digital Ocean

### Prerequisites

1. Terraform installed on your local machine.
2. A Digital Ocean account with an API token.
3. A registered SSH key in your Digital Ocean account. Register it [here](https://cloud.digitalocean.com/account/security).

```bash
# Set required environment variables
export TF_LOG=INFO
export DO_PAT=dop_v1_...
```

### Deployment Commands

Navigate to the DigitalOcean infrastructure directory:
```bash
cd infrastructure/digitalocean
```

Initialize Terraform:
```bash
terraform init 
```

#### Plan deployment

Re-run this command when you change the infrastructure configuration

```bash
terraform plan -var "do_token=${DO_PAT}" -var "digital_ocean_ssh_key=My-Personal-Key"
```

By default, the droplets are set to be created under the BAS project, you can specify a different project by adding
`-var "digitalocean_project=Your-Project-Name"` flag to the commands.

#### Deploy infrastructure

Remember to replace My-Personal-Key with your actual key you registered on the digital ocean dashboard. Also, use a secure database password

```bash
terraform apply -var "do_token=${DO_PAT}" -var "digital_ocean_ssh_key=My-Personal-Key" -var "pvt_key=~/.ssh/id_rsa" -var "database_password=my-password"
```

Sometimes it may be necessary to refresh the state after making changes outside terraform or if the initial deployment fails. You can do this with the following command:

```bash
# Refresh state (if needed)
terraform refresh -var "do_token=${DO_PAT}" -var "digital_ocean_ssh_key=My-Personal-Key"
```

#### Destroy Infrastructure

If you were testing and want to remove the infrastructure, you can use the following command.

> [!CAUTION]
> This will destroy all resources created by Terraform and cannot be undone. Make sure you have backups of any important data.

```bash
terraform destroy -var "do_token=${DO_PAT}" -var "digital_ocean_ssh_key=My-Personal-Key"
```

## Using Amazon Web Services (AWS)

### Prerequisites
1. Terraform installed on your local machine.
2. An AWS account with an IAM user that has permissions to create EC2 instances, security groups, VPCs, and other necessary resources.
3. Install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) and configure it with your credentials.
4. Create an EC2 Key Pair in your desired AWS region.

```bash
# Set required environment variables
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
```

### Deployment Commands

Navigate to the AWS infrastructure directory:
```bash
cd infrastructure/aws
```

Initialize Terraform:
```bash
terraform init
```

#### Plan deployment
```bash
terraform plan -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" -var "aws_key_pair_name=My-Personal-Key"
```

#### Deploy infrastructure
Replace `My-Personal-Key` with your actual AWS key pair name:
```bash
terraform apply -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" -var "aws_key_pair_name=My-Personal-Key" -var "pvt_key=~/.ssh/id_rsa" -var "database_password=my-password"
```

#### Destroy Infrastructure
```bash
terraform destroy -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" -var "aws_key_pair_name=My-Personal-Key"
```

## Configuration Options

### Optional Variables

Both providers support these optional configurations:

**Database Password**: 
- Default: `ChangeMeASAP!` 
- Always use a secure password in production

**AWS Specific**:
- `instance_type`: EC2 instance type (default: `t2.micro`)
- `aws_region`: Deployment region (default: `us-east-1`)
- `vpc_cidr`: VPC CIDR block (default: `10.10.10.0/24`)

**Digital Ocean Specific**:
- `digitalocean_project`: Project name (default: `BAS`)

## Post-Deployment

After successful deployment:

1. **Application Setup**: SSH into the application server and configure the BAS system
2. **Database Setup**: The database is automatically configured with initial structure
3. **Security**: Update default passwords and review security group rules
4. **Monitoring**: Check instance logs and connectivity between servers

## Troubleshooting

- **Terraform State Issues**: Use `terraform refresh` to sync state
- **SSH Connection Problems**: Verify key pair configuration and security groups
- **Resource Conflicts**: Check for existing resources with same names
- **apt Lock Issues**: The installation script includes automatic handling of apt locks
