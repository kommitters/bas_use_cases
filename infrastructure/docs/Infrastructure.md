# BAS Infrastructure Documentation

This document describes the infrastructure setup for the BAS (Bot Automation System) project, which supports both DigitalOcean and AWS cloud providers.

## Overview

The infrastructure creates a simple two-server setup:
- **BAS Server**: Main application server with Docker installed
- **BAS Database**: PostgreSQL database server running in Docker containers
- **Private Network**: Internal networking for secure communication between servers

## Architecture

Both cloud providers implement the same logical architecture:

```
Internet
    |
[Load Balancer/Internet Gateway]
    |
[Private Network: 10.10.10.0/24]
    |
    +-- BAS Server (App Server)
    |   - Docker installed
    |   - Environment variables configured
    |   - Connects to database on port 8001
    |
    +-- BAS Database Server
        - PostgreSQL 16.9 running in Docker
        - Database: 'bas' 
        - Table: 'generic_data' (JSONB storage)
        - Exposed on port 8001 (mapped to 5432 internally)
```

## DigitalOcean Implementation

### Resources Created
- **VPC**: `bas-network` (10.10.10.0/24) in NYC3 region
- **Droplets**: 2x s-1vcpu-1gb Ubuntu 24.10 instances
- **Project Assignment**: Resources assigned to BAS project

### Configuration
```hcl
# Required Variables
do_token                = "your-digitalocean-api-token"
digital_ocean_ssh_key   = "your-ssh-key-name"
digitalocean_project    = "BAS"  # default
database_password       = "ChangeMeASAP!"  # default
pvt_key                = "~/.ssh/id_rsa"  # default
```

## AWS Implementation  

### Resources Created
- **VPC**: `bas-network` (10.10.10.0/24) in us-east-1 region (configurable)
- **Internet Gateway**: For public internet access
- **Public Subnet**: Single subnet spanning the VPC CIDR
- **Security Groups**: Separate groups for server and database with minimal required ports
- **EC2 Instances**: 2x t3.micro Ubuntu 24.10 instances
- **Route Tables**: Public routing configuration

### Configuration
```hcl
# Required Variables
aws_access_key      = "your-aws-access-key"
aws_secret_key      = "your-aws-secret-key" 
aws_key_pair_name   = "your-ec2-key-pair-name"

# Optional Variables (with defaults)
aws_region          = "us-east-1"
instance_type       = "t3.micro"  # AWS equivalent of DO s-1vcpu-1gb
vpc_cidr           = "10.10.10.0/24"
database_password   = "ChangeMeASAP!"
pvt_key            = "~/.ssh/id_rsa"
```

## Common Resources

Both implementations reuse shared resources from `/common/`:

### Scripts
- **`install_docker_on_ubuntu.sh`**: Installs Docker CE with compose plugin
  - Handles apt lock conflicts gracefully
  - Removes conflicting packages
  - Adds official Docker repository
  
- **`db_docker-compose.yml`**: PostgreSQL container configuration
  - PostgreSQL 16.9 Alpine image
  - Port mapping: 8001 (host) → 5432 (container)
  - Persistent volume for data storage
  - External network: `db_net`

- **`create_basic_db_structure.sql`**: Database schema initialization
  - Creates `bas` database
  - Creates `generic_data` table with JSONB storage
  - Sets up auto-incrementing ID sequence

### Templates
- **`env_vars.tftpl`**: Cloud-init template for environment variables
  - Creates `/db/.env` with PostgreSQL password
  - Used by both providers via `templatefile()`

## Security Considerations

### Network Security
- **DigitalOcean**: Uses VPC with private networking
- **AWS**: Uses VPC with security groups for fine-grained access control

### Access Control
- SSH access requires private key authentication
- Database only accessible from BAS server on port 8001
- No direct internet access to database port 5432

### Default Assumptions
- **SSH Key**: Assumes SSH key pair already exists in cloud provider
- **Database Password**: Default password should be changed in production
- **Instance Sizes**: Minimal sizes chosen for cost optimization
- **Regions**: Default regions chosen for low latency (NYC3 for DO, us-east-1 for AWS)

## Usage

### DigitalOcean Deployment
```bash
cd infrastructure/digitalocean
terraform init
terraform plan
terraform apply
```

### AWS Deployment  
```bash
cd infrastructure/aws
terraform init
terraform plan
terraform apply
```

### Environment Setup
Both deployments require:
1. Cloud provider credentials configured
2. SSH key pair created in the cloud provider console
3. Variables file or environment variables set
4. Terraform installed locally

## Database Connection

After deployment, the BAS server will have these environment variables:
- `DB_HOST`: Private IP of database server
- `DB_PORT`: 8001 
- `PGPASSWORD`: Database password

## Maintenance Notes

### Docker Management
- Docker containers restart automatically (`unless-stopped` policy)
- PostgreSQL data persists in named volume `postgres_data`
- Database network isolated via `db_net` external network

### Instance Access
- **DigitalOcean**: Login as `root` user
- **AWS**: Login as `ubuntu` user (Ubuntu AMI default)
- Both require SSH private key authentication

### Scaling Considerations
- Current setup is minimal for development/testing
- For production: consider load balancers, auto-scaling groups, managed databases
- Database backup strategy not implemented (should be added for production)